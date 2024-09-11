//
//  DeeplinksProvider.swift
//
//
//  Created by Odinokov G. A. on 08.09.2024.
//

import Foundation

/// A provider protocol for retrieving available deeplinks.
///
/// The `DeeplinksProvider` protocol defines a method for retrieving a collection of deeplinks
/// that can be processed by the application. Implement this protocol to supply a list of
/// `Deeplinkable` objects that represent the deeplinks supported by the application.
public protocol DeeplinksProvider {
    /// Retrieves a list of available deeplinks.
    ///
    /// - Returns: An array of `Deeplinkable` objects representing the supported deeplinks.
    func getDeeplinks() -> [any Deeplinkable]
}
