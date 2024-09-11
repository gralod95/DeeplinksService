//
//  DeeplinksServiceFactory.swift
//
//
//  Created by Odinokov G. A. on 08.09.2024.
//

import Foundation

public struct DeeplinksServiceFactory {
    // MARK: - Nested types

    /// A configuration struct for the deeplink service.
    public struct DeeplinkServiceConfiguration {
        /// Configuration for parsing parameters from deeplinks.
        public let parametersConfiguration: DeeplinkParametersConfiguration
        /// The app's URL scheme used for deeplinks.
        public let appUrlScheme: String

        init(parametersConfiguration: DeeplinkParametersConfiguration, appUrlScheme: String) {
            self.parametersConfiguration = parametersConfiguration
            self.appUrlScheme = appUrlScheme
        }
    }

    /// A struct that holds the necessary sources for managing deeplinks.
    public struct DeeplinkServiceSources {
        /// The provider responsible for supplying the available deeplinks.
        public let deeplinksProvider: DeeplinksProvider
        /// The delegate that handles navigation when handling a deeplink.
        public let coordinatorDelegate: DeeplinkCoordinatorDelegate
        /// The data source responsible for providing view controllers for deeplink handling.
        public let coordinatorDataSource: DeeplinkCoordinatorDataSource
        /// An optional delegate responsible for converting universal links into deeplinks.
        public let universalDeeplinksDelegate: UniversalDeeplinksDelegate?

        init(
            deeplinksProvider: DeeplinksProvider,
            coordinatorDelegate: DeeplinkCoordinatorDelegate,
            coordinatorDataSource: DeeplinkCoordinatorDataSource,
            universalDeeplinksDelegate: UniversalDeeplinksDelegate?
        ) {
            self.deeplinksProvider = deeplinksProvider
            self.coordinatorDelegate = coordinatorDelegate
            self.coordinatorDataSource = coordinatorDataSource
            self.universalDeeplinksDelegate = universalDeeplinksDelegate
        }
    }

    // MARK: - Public methods

    public func makeDeeplinkService(
        configuration: DeeplinkServiceConfiguration,
        sources: DeeplinkServiceSources
    ) -> DeeplinkService {
        let urlsProvider = makeUrlsProvider(universalDeeplinksDelegate: sources.universalDeeplinksDelegate)
        let urlComparator = makeUrlComparator(
            urlsProvider: urlsProvider,
            parametersConfiguration: configuration.parametersConfiguration,
            appUrlScheme: configuration.appUrlScheme
        )
        let urlParser = makeUrlParser(urlsProvider: urlsProvider)
        let coordinator = makeCoordinator(
            delegate: sources.coordinatorDelegate,
            dataSource: sources.coordinatorDataSource
        )

        return DeeplinkServiceImplementation(
            urlComparator: urlComparator,
            urlParser: urlParser,
            coordinator: coordinator,
            deeplinksProvider: sources.deeplinksProvider
        )
    }

    // MARK: - Private methods

    private func makeUrlComparator(
        urlsProvider: UrlsProvider,
        parametersConfiguration: DeeplinkParametersConfiguration,
        appUrlScheme: String
    ) -> UrlComparator {
        UrlComparatorImplementation(
            urlsProvider: urlsProvider,
            parametersConfiguration: parametersConfiguration,
            appUrlScheme: appUrlScheme
        )
    }

    private func makeUrlParser(urlsProvider: UrlsProvider) -> UrlParser {
        UrlParserImplementation(urlsProvider: urlsProvider)
    }

    private func makeCoordinator(
        delegate: DeeplinkCoordinatorDelegate,
        dataSource: DeeplinkCoordinatorDataSource
    ) -> DeeplinkCoordinator {
        DeeplinkCoordinatorImplementation(delegate: delegate, dataSource: dataSource)
    }

    private func makeUrlsProvider(universalDeeplinksDelegate: UniversalDeeplinksDelegate?) -> UrlsProvider {
        UrlsProviderImplementation(universalDeeplinksDelegate: universalDeeplinksDelegate)
    }
}
