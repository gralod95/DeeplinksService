//
//  DeeplinksProviderMock.swift
//
//
//  Created by Odinokov G. A. on 09.09.2024.
//

import Foundation
import DeeplinksService

final class DeeplinksProviderMock: DeeplinksProvider {
    // MARK: - Public properties

    var mocks: [any DeeplinksService.Deeplinkable] = []

    // MARK: - DeeplinksProvider

    func getDeeplinks() -> [any DeeplinksService.Deeplinkable] {
        mocks
    }
}
