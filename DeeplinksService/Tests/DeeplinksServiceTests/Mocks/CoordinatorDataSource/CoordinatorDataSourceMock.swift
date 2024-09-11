//
//  CoordinatorDataSourceMock.swift
//  
//
//  Created by Odinokov G. A. on 09.09.2024.
//

import Foundation
import UIKit
import DeeplinksService

final class CoordinatorDataSourceMock: DeeplinkCoordinatorDataSource {
    // MARK: - Public properties

    var provideLoader: (() -> UIViewController)?
    var providePresenter: (() -> UIViewController)?

    // MARK: - DeeplinkCoordinatorDataSource

    func getLoaderViewController() -> UIViewController {
        provideLoader?() ?? .init()
    }

    func getPresenterViewController() -> UIViewController {
        providePresenter?() ?? .init()
    }
}
