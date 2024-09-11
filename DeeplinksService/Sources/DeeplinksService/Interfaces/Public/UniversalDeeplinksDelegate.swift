//
//  UniversalDeeplinksDelegate.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 05.09.2024.
//

import Foundation

/// A delegate protocol for handling universal links and converting them into deeplinks.
public protocol UniversalDeeplinksDelegate {
    /// Converts a universal link into a deeplink.
    /// 
    /// - Parameter universalLink: The universal link (URL) that needs to be converted.
    /// - Returns: A URL representing the deeplink if the conversion is successful.
    func makeDeepLink(universalLink: URL) -> URL?
}
