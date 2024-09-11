//
//  DeeplinkWithPathAndParametersMock.swift
//
//
//  Created by Odinokov G. A. on 10.09.2024.
//

import Foundation
import DeeplinksService

final class DeeplinkWithPathItemsAndParametersMock<Parameters: Decodable>: Deeplinkable {
    // MARK: - Public properties

    let onExecuting: (_ pathItems: [String], _ parameters: Parameters) -> Void
    let onError: () -> Void
    let path: DeeplinkPath
    let needPreloader: Bool
    let needPopToRoot: Bool

    // MARK: - Initiation

    init(
        path: DeeplinkPath,
        needPreloader: Bool,
        needPopToRoot: Bool,
        onExecuting: @escaping (_ pathItems: [String], _ parameters: Parameters) -> Void,
        onError: @escaping () -> Void = {}
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
            .success(.custom({ self.onExecuting(pathItems, parameters) }))
        )
    }

    func handleError(_ error: DeeplinksService.DeeplinkProcessingError) -> DeeplinksService.DeeplinkAction? {
        onError()
        return nil
    }
}
