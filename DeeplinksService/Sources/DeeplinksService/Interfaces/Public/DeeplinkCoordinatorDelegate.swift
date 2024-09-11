//
//  DeeplinkCoordinatorDelegate.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 07.09.2024.
//

import Foundation

/// A delegate protocol that defines navigation behavior when handling a deeplink.
public protocol DeeplinkCoordinatorDelegate {
    /// Navigates to the root view controller and then executes a completion handler.
    func routeToRootViewController(completion: @escaping () -> Void)
}
