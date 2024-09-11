//
//  Deeplink.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 03.09.2024.
//

import UIKit

public protocol Deeplinkable<Parameters> {
    associatedtype Parameters: Decodable

    /// The path that identifies the deeplink.
    var path: DeeplinkPath { get }
    /// Indicates whether a loading state (spinner) should be shown before opening the deeplink.
    var needPreloader: Bool { get }
    /// Indicates whether all screens should be closed and the app should return to the root screen before opening the deeplink.
    var needPopToRoot: Bool { get }

    /// Handles the deeplink with the specified path items and parameters.
    ///
    /// This method is responsible for handling the deeplink after it has been matched.
    ///
    /// - Parameters:
    ///   - pathItems: An array of strings representing the components of the deeplink path.
    ///   - parameters: The parameters decoded from the deeplink.
    ///   - completion: An escaping closure, which should  be performed after the deeplink is processed.
    func handle(
        pathItems: [String],
        parameters: Parameters,
        completion: @escaping (Result<DeeplinkAction, Error>) -> Void
    )

    /// Handles errors that occur during the processing of a deeplink.
    ///
    /// This method is called when an error occurs while handling the deeplink. The method should
    /// return a `DeeplinkAction` that specifies how to respond to the error.
    ///
    /// - Parameter error: The error that occurred during deeplink processing.
    /// - Returns: A `DeeplinkAction` that defines the action to be performed in response to the error.
    func handleError(_ error: DeeplinkProcessingError) -> DeeplinkAction?
}
