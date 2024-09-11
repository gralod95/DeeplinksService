//
//  DeeplinkServiceImplementation.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 04.09.2024.
//

import UIKit

final class DeeplinkServiceImplementation: DeeplinkService {

    // MARK: - Private properties

    private let urlComparator: UrlComparator
    private let urlParser: UrlParser
    private var coordinator: DeeplinkCoordinator
    private let deeplinksProvider: DeeplinksProvider

    // MARK: - Init

    init(
        urlComparator: UrlComparator,
        urlParser: UrlParser,
        coordinator: DeeplinkCoordinator,
        deeplinksProvider: DeeplinksProvider
    ) {
        self.urlComparator = urlComparator
        self.urlParser = urlParser
        self.coordinator = coordinator
        self.deeplinksProvider = deeplinksProvider
    }

    // MARK: - Public methods

    func getDeeplink(url: URL) throws -> (any Deeplinkable)? {
        try deeplinksProvider.getDeeplinks()
            .first { try urlComparator.urlMatches(url: url, path: $0.path) }
    }

    func process<Deeplink, Parameters>(
        deeplink: Deeplink,
        url: URL,
        onError: @escaping (DeeplinkProcessingError) -> Void
    ) where Deeplink: Deeplinkable, Parameters == Deeplink.Parameters {
        let urlInfo = urlParser.getPathInfo(from: url)
        let parametersResult: Result<Parameters, Error> = urlParser.makeParameters(from: urlInfo.parameters)

        switch parametersResult {
        case .success(let parameters):
            processDeeplink(
                deeplink: deeplink,
                pathItems: urlInfo.pathItems,
                parameters: parameters,
                onError: onError
            )
        case .failure(let error):
            processDeeplinkError(
                deeplink: deeplink,
                error: .parsingParametersFailed(error),
                onError: onError
            )
        }
    }

    // MARK: - Private Methods

    private func processDeeplink<Deeplink, Parameters>(
        deeplink: Deeplink,
        pathItems: [String],
        parameters: Parameters,
        onError: @escaping (DeeplinkProcessingError) -> Void
    )  where Deeplink: Deeplinkable, Parameters == Deeplink.Parameters {
        coordinator.prepareForOpening(
            deeplink: deeplink
        ) {
            deeplink.handle(
                pathItems: pathItems,
                parameters: parameters
            ) { [weak self] result in
                self?.processDeeplinkResult(result, deeplink: deeplink, onError: onError)
            }
        }
    }

    private func processDeeplinkResult(
        _ result: Result<DeeplinkAction, Error>,
        deeplink: any Deeplinkable,
        onError: @escaping (DeeplinkProcessingError) -> Void
    ) {
        switch result {
        case let .success(action):
            coordinator.perform(action: action)
        case let .failure(error):
            processDeeplinkError(
                deeplink: deeplink,
                error: .failedToHandleDeeplink(error),
                onError: onError
            )
        }
    }

    private func processDeeplinkError(
        deeplink: any Deeplinkable,
        error: DeeplinkProcessingError,
        onError: @escaping (DeeplinkProcessingError) -> Void
    ) {
        coordinator.clearAfterError()

        let errorAction = deeplink.handleError(error)
        onError(error)

        guard let errorAction else { return }
        
        coordinator.perform(action: errorAction)
    }
}
