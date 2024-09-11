//
//  DeeplinkMockWithAction.swift
//
//
//  Created by Odinokov G. A. on 11.09.2024.
//

import Foundation
import DeeplinksService

final class DeeplinkMockWithAction: Deeplinkable {
    // MARK: - Nested types

    typealias Parameters = EmptyDeeplinkParameters

    // MARK: - Public properties

    let onExecuting: () -> Result<DeeplinkAction, any Error>
    let onError: (DeeplinksService.DeeplinkProcessingError) -> DeeplinksService.DeeplinkAction?
    let path: DeeplinkPath
    let needPreloader: Bool
    let needPopToRoot: Bool

    // MARK: - Initiation

    init(
        path: DeeplinkPath,
        needPreloader: Bool,
        needPopToRoot: Bool,
        onExecuting: @escaping () -> Result<DeeplinkAction, any Error>,
        onError: @escaping (DeeplinksService.DeeplinkProcessingError) -> DeeplinksService.DeeplinkAction?
    ) {
        self.path = path
        self.needPreloader = needPreloader
        self.needPopToRoot = needPopToRoot
        self.onExecuting = onExecuting
        self.onError = onError
    }
    
    // MARK: - Deeplinkable

    func handle(
        pathItems: [String],
        parameters: Parameters,
        completion: @escaping (Result<DeeplinkAction, any Error>) -> Void
    ) {
        completion(
            self.onExecuting()
        )
    }

    func handleError(_ error: DeeplinksService.DeeplinkProcessingError) -> DeeplinksService.DeeplinkAction? {
        onError(error)
    }
}
