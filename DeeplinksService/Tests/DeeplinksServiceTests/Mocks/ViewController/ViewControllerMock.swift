//
//  ViewControllerMock.swift
//
//
//  Created by Odinokov G. A. on 11.09.2024.
//

import UIKit

final class ViewControllerMock: UIViewController {
    // MARK: - Public properties

    var onPresent: ((UIViewController) -> Void)?
    var onDismiss: (() -> Void)?
    var onShow: ((UIViewController) -> Void)?
    var onShowDetail: ((UIViewController) -> Void)?
    var isBeingPresentedMock: Bool = false
    var mockViewControllerToPresent: UIViewController?

    // MARK: - Override
    
    override var isBeingPresented: Bool {
        isBeingPresentedMock
    }

    override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        super.present(viewControllerToPresent, animated: flag)

        onPresent?(viewControllerToPresent)

        (viewControllerToPresent as? ViewControllerMock)?.isBeingPresentedMock = true
        mockViewControllerToPresent = viewControllerToPresent

        completion?()
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag)

        onDismiss?()
        isBeingPresentedMock = false

        completion?()
    }

    override func show(_ vc: UIViewController, sender: Any?) {
        onShow?(vc)
    }

    override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
        onShowDetail?(vc)
    }
}
