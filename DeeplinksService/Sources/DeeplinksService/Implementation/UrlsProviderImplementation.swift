//
//  UrlsProviderImplementation.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 05.09.2024.
//

import Foundation

struct UrlsProviderImplementation: UrlsProvider {
    // MARK: - Private properties
    
    private let universalDeeplinksDelegate: UniversalDeeplinksDelegate?

    // MARK: - Init

    init(universalDeeplinksDelegate: UniversalDeeplinksDelegate?) {
        self.universalDeeplinksDelegate = universalDeeplinksDelegate
    }
    
    // MARK: - Public methods

    func getUrl(originalUrl: URL) -> URL {
        universalDeeplinksDelegate?.makeDeepLink(universalLink: originalUrl) ?? originalUrl
    }
}
