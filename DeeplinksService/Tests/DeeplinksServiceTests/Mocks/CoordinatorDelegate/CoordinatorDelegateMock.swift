//
//  CoordinatorDelegateMock.swift
//  
//
//  Created by Odinokov G. A. on 09.09.2024.
//

import Foundation
import DeeplinksService

final class CoordinatorDelegateMock: DeeplinkCoordinatorDelegate {
    // MARK: - Public properties

    var routeToRootAction: (() -> Void)?

    // MARK: - DeeplinkCoordinatorDelegate

    func routeToRootViewController(completion: @escaping () -> Void) {
        routeToRootAction?()
        completion()
    }
}
