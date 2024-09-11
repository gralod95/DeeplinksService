//
//  DeeplinkCoordinatorImplementation.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 07.09.2024.
//

import UIKit

class DeeplinkCoordinatorImplementation: DeeplinkCoordinator {
    // MARK: - Private properties

    private weak var preloaderScene: UIViewController?
    private let delegate: DeeplinkCoordinatorDelegate
    private let dataSource: DeeplinkCoordinatorDataSource

    // MARK: - Init

    init(delegate: DeeplinkCoordinatorDelegate, dataSource: DeeplinkCoordinatorDataSource) {
        self.delegate = delegate
        self.dataSource = dataSource
    }

    // MARK: - Public methods

    func prepareForOpening(
        deeplink: any Deeplinkable,
        completion: @escaping () -> Void
    ) {
        dismissOpenedControllersIfNeeded(deeplink: deeplink) {
            self.presentLoaderIfNeededSafely(deeplink: deeplink, completion: completion)
        }
    }

    func perform(action: DeeplinkAction) {
        guard let preloaderScene, preloaderScene.isBeingPresented else { execute(action: action); return }

        preloaderScene.dismiss(animated: true) { [weak self] in self?.execute(action: action) }
    }

    func clearAfterError() {
        preloaderScene?.dismiss(animated: true)
        preloaderScene = nil
    }

    // MARK: - Private methods

    private func dismissOpenedControllersIfNeeded(
        deeplink: any Deeplinkable,
        completion: @escaping () -> Void
    ) {
        guard deeplink.needPopToRoot else { return completion() }

        delegate.routeToRootViewController(completion: completion)
    }

    private func presentLoaderIfNeededSafely(
        deeplink: any Deeplinkable,
        completion: @escaping () -> Void
    ) {
        dismissPreloader { [weak self] in self?.presentLoaderIfNeeded(deeplink: deeplink, completion: completion) }
    }

    private func dismissPreloader(completion: @escaping () -> Void) {
        guard let preloaderScene else { completion(); return }

        preloaderScene.dismiss(animated: false, completion: completion)
    }

    private func presentLoaderIfNeeded(
        deeplink: any Deeplinkable,
        completion: @escaping () -> Void
    ) {
        guard deeplink.needPreloader else { completion(); return }

        let preloaderScene = dataSource.getLoaderViewController()
        let presenter = dataSource.getPresenterViewController()
        self.preloaderScene = preloaderScene

        presenter.present(preloaderScene, animated: false, completion: completion)
    }

    private func execute(action: DeeplinkAction) {
        switch action {
        case .present(let viewController, let strategy):
            let presenter = dataSource.getPresenterViewController()
            switch strategy {
            case .show:
                presenter.show(viewController, sender: nil)
            case .showDetailViewController:
                presenter.showDetailViewController(viewController, sender: nil)
            }
        case .custom(let pieceOfWork):
            pieceOfWork()
        case .customWithPresenter(let pieceOfWork):
            let presenter = dataSource.getPresenterViewController()

            pieceOfWork(presenter)
        }
    }
}
