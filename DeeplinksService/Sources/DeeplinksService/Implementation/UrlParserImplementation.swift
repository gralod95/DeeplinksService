//
//  UrlParserImplementation.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 05.09.2024.
//

import Foundation

struct UrlParserImplementation: UrlParser {
    // MARK: - Nested types

    private enum Constants {
        static let pathItemsSeparator = "/"
    }

    // MARK: - Private properties

    private let urlsProvider: UrlsProvider
    private let decoder: JSONDecoder

    // MARK: - Init

    init(urlsProvider: UrlsProvider) {
        self.urlsProvider = urlsProvider

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: - Public methods

    func getPathInfo(from url: URL) -> UrlInfo {
        let finalUrl = urlsProvider.getUrl(originalUrl: url)
        let components = URLComponents(url: finalUrl, resolvingAgainstBaseURL: true)

        guard let components else { return .init(pathItems: [], parameters: [:]) }

        let host = [components.host].compactMap { $0 }
        let pathItems = host + getPathItems(from: components)
        let parameters = getParametersDictionary(from: components) ?? [:]

        return .init(pathItems: pathItems, parameters: parameters)
    }

    func makeParameters<Parameters: Decodable>(from parametersDictionary: [String: String]) -> Result<Parameters, Error> {
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: parametersDictionary, options: .prettyPrinted)
            let parameters = try decoder.decode(Parameters.self, from: data)

            return .success(parameters)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Private methods

    private func getPathItems(from components: URLComponents) -> [String] {
        components
            .path
            .components(separatedBy: Constants.pathItemsSeparator)
            .filter { !$0.isEmpty }
    }

    private func getParametersDictionary(from components: URLComponents) -> [String: String]? {
        components
            .queryItems?
            .reduce(into: [:]) {
            $0[$1.name] = $1.value
        }
    }
}
