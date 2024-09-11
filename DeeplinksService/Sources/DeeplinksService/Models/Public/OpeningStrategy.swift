//
//  OpeningStrategy.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 03.09.2024.
//

import Foundation

/// Defines the strategy for presenting a `UIViewController`.
public enum PresentingStrategy {
    /// Presents a view controller in a primary context.
    ///
    /// This strategy uses the [`show`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621377-show) method
    case show
    /// Presents a view controller in a secondary (or detail) context.
    ///
    /// This strategy uses the [`showDetailViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621432-showdetailviewcontroller) method
    case showDetailViewController
}
