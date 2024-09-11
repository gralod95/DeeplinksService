//
//  DeeplinkCoordinator.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 04.09.2024.
//

import Foundation
import UIKit

protocol DeeplinkCoordinator {
    func prepareForOpening(deeplink: any Deeplinkable, completion: @escaping () -> Void)

    func perform(action: DeeplinkAction)

    func clearAfterError()
}
