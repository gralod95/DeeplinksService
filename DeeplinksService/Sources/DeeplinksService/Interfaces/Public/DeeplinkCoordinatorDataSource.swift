//
//  DeeplinkCoordinatorDataSource.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 08.09.2024.
//

import UIKit

/// A data source protocol that provides view controllers used during the deeplink handling process.
public protocol DeeplinkCoordinatorDataSource {
    /// Returns the view controller that displays a loading state (spinner) while the deeplink is being processed.
    func getLoaderViewController() -> UIViewController
    
    /// Returns the view controller that will be used to present the content triggered by the deeplink.
    func getPresenterViewController() -> UIViewController
}
