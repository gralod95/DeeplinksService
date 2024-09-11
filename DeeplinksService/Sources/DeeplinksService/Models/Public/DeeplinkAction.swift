//
//  DeeplinkAction.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 03.09.2024.
//

import UIKit

/// Action to be performed when executing a deeplink.
public enum DeeplinkAction {
    /// Presents a view controller with a specific strategy
    /// - Parameters:
    ///   - viewController: The view controller that should be presented.
    ///   - strategy: The strategy to use when presenting the view controller.
    case present(viewController: UIViewController, strategy: PresentingStrategy)
    /// Executes a custom closure.
    /// - Parameters:
    ///   - closure: A closure that will be executed when the deeplink is triggered.
    case custom(() -> Void)
    /// Executes a custom closure with a presenter view controller.
    /// - Parameters:
    ///   - closure: A closure that will be executed with the provided presenter when the deeplink is triggered.
    case customWithPresenter((_ presenter: UIViewController) -> Void)
}
