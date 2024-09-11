//
//  DeeplinkService.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 03.09.2024.
//

import UIKit

/// A service protocol responsible for retrieving and processing deeplinks.
public protocol DeeplinkService {
    /// Retrieves a deeplink object that matches the provided URL.
    ///
    /// - Parameter url: The URL of the deeplink to be processed.
    /// - Returns: A `Deeplinkable` object that matches the URL, or `nil` if no match is found.
    func getDeeplink(url: URL) throws -> (any Deeplinkable)?

    /// Processes the specified deeplink, including handling errors that may occur.
    ///
    /// - Parameters:
    ///   - deeplink: The `Deeplinkable` object to be processed.
    ///   - url: The URL associated with the deeplink.
    ///   - onError: A closure that is called when an error occurs during the processing of the deeplink.
    /// - Note: The `Parameters` type must match the `Deeplinkable`'s associated type `Parameters`.
    func process<Deeplink, Parameters>(
        deeplink: Deeplink,
        url: URL,
        onError: @escaping (DeeplinkProcessingError) -> Void
    ) where Deeplink: Deeplinkable, Parameters == Deeplink.Parameters
}
