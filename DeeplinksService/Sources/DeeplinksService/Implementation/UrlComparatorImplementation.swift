//
//  UrlComparatorImplementation.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 05.09.2024.
//

import Foundation


struct UrlComparatorImplementation: UrlComparator {
    // MARK: - Nested types

    private enum Constants {
        static let startsOfPathItem = "/"
        static let startsOfParameters = "?"
        static let startsOfNextParameters = "&"

        static let pathRegex = "^%@$"

        static let firstItemPrefixRegex = "("
        static let prefixRegex = "|("
        static let suffixRegex = ")"

        static let parameterAsPathRegex = "([^=&?/]+)"
        static let parameterAtStartOfPathItemRegex = "(/[^=&?/]+)"
        static let parameterAtStartOfParametersItemRegex = "(\\?[^&/]+=[^&/]+)"
        static let nextParameterRegex = "(&[^&/]+=[^&/]+)"

        static let optionalRegex = "?"
        static let onlyOneRegex = "{1}"

        static let swiftStringSpecialCharacters = [("_", "\\_"), ("?", "\\?")]
    }

    // MARK: - Private properties

    private let urlsProvider: UrlsProvider
    private let parametersConfiguration: DeeplinkParametersConfiguration
    private let appUrlScheme: String

    // MARK: - Init

    init(
        urlsProvider: UrlsProvider,
        parametersConfiguration: DeeplinkParametersConfiguration,
        appUrlScheme: String
    ) {
        self.urlsProvider = urlsProvider
        self.parametersConfiguration = parametersConfiguration
        self.appUrlScheme = appUrlScheme
    }

    // MARK: - Public methods

    func urlMatches(url: URL, path: DeeplinkPath) throws -> Bool {
        var urlString = urlsProvider.getUrl(originalUrl: url).absoluteString
        let regularExpression = try makeRegularExpression(path: path)

        guard urlString.hasPrefix(appUrlScheme) else { return false }

        urlString.removeFirst(appUrlScheme.count)
        let range = NSRange(location: .zero, length: urlString.utf16.count)

        return regularExpression.firstMatch(in: urlString, options: [], range: range) != nil
    }

    // MARK: - Private methods
    
    private func makeRegularExpression(path: DeeplinkPath) throws -> NSRegularExpression {
        let pattern = try getPattern(path: path)
        
        do {
            return try NSRegularExpression(pattern: pattern)
        } catch let error {
            throw DeeplinkProcessingError.pathIsIncorrect(path: path, error: error)
        }
    }

    private func getPattern(path: DeeplinkPath) throws -> String {
        switch path {
        case let .paths(paths):
            return try getRegexText(for: paths)
        case let .regularExpression(text):
            return text
        }
    }

    private func getRegexText(for paths: [String]) throws -> String {
        let regexTexts = try paths.map(getRegexText(for:))

        guard regexTexts.count != 1 else { return regexTexts[.zero] }

        return regexTexts
            .enumerated()
            .reduce(into: String()) { result, item in
                result += item.offset == .zero ? Constants.firstItemPrefixRegex : Constants.prefixRegex
                result += String(item.element)
                result += Constants.suffixRegex
            }
    }

    private func getRegexText(for path: String) throws -> String {
        let hasParameters = path.contains(parametersConfiguration.beginningSymbol)

        return .init(
            format: Constants.pathRegex,
            hasParameters ? try getRegexTextWithParameters(for: path) : path
        )
    }

    private func getRegexTextWithParameters(for path: String) throws -> String {
        let parametersRanges = getParametersRanges(path: path)

        var searchingStartIndex = path.startIndex
        var regex = String()

        try parametersRanges.forEach { parameterRange in
            let textBeforeParameterRange = searchingStartIndex..<parameterRange.lowerBound
            var textBeforeParameter = path[textBeforeParameterRange]

            let firstChar = textBeforeParameter.isEmpty ? String() : String(textBeforeParameter.removeLast())
            let parameter = firstChar + path[parameterRange]

            regex += convertSpecialChars(in: textBeforeParameter)
            regex += try convertParameter(parameter)

            searchingStartIndex = path.index(after: parameterRange.upperBound)
        }

        if path.indices.contains(searchingStartIndex) {
            regex += convertSpecialChars(in: path[searchingStartIndex...])
        }

        return regex
    }

    private func getParametersRanges(path: String) -> [ClosedRange<String.Index>] {
        let parametersCount = path.filter { $0 == parametersConfiguration.beginningSymbol }.count

        var startIndex: String.Index?
        var ranges: [ClosedRange<String.Index>] = []

        ranges.reserveCapacity(parametersCount)

        zip(path.indices, path).forEach { index, character in
            switch character {
            case parametersConfiguration.beginningSymbol:
                startIndex = index
            case parametersConfiguration.endsSymbol:
                if let startIndex {
                    ranges.append(startIndex...index)
                }
                startIndex = nil
            default:
                break
            }
        }

        return ranges
    }

    private func convertParameter(_ parameterText: String) throws -> String {
        let prefix = parameterText.prefix(1)
        let isOptional = parameterText.suffix(2).first == parametersConfiguration.optionalSymbol
        let parameterSuffix = isOptional ? Constants.optionalRegex : Constants.onlyOneRegex

        let regex: String
        switch prefix {
        case Constants.startsOfPathItem:
            regex = Constants.parameterAtStartOfPathItemRegex
        case Constants.startsOfParameters:
            regex = Constants.parameterAtStartOfParametersItemRegex
        case Constants.startsOfNextParameters:
            regex = Constants.nextParameterRegex
        case String(parametersConfiguration.beginningSymbol):
            regex = Constants.parameterAsPathRegex
        default:
            throw DeeplinkProcessingError.invalidParameterPosition(parameter: parameterText)
        }

        return regex + parameterSuffix
    }

    private func convertSpecialChars(in text: Substring) -> String {
        var result: String = .init()
        Constants.swiftStringSpecialCharacters.forEach { (whatToChange, with) in
            result = text.replacingOccurrences(of: whatToChange, with: with)
        }

        return result
    }
}
