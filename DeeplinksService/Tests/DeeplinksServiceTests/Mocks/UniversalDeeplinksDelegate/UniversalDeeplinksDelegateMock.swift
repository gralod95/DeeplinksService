//
//  UniversalDeeplinksDelegateMock.swift
//
//
//  Created by Odinokov G. A. on 09.09.2024.
//

import Foundation
import DeeplinksService


final class UniversalDeeplinksDelegateMock: UniversalDeeplinksDelegate {
    // MARK: - Public properties

    var map: [URL: URL] = [:]

    // MARK: - UniversalDeeplinksDelegate

    func makeDeepLink(universalLink: URL) -> URL? {
        map[universalLink]
    }
}
