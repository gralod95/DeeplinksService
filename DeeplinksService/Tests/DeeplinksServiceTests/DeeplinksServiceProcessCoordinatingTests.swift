//
//  DeeplinksServiceProcessCoordinatingTests.swift
//  
//
//  Created by Odinokov G. A. on 11.09.2024.
//

import XCTest
@testable import DeeplinksService

final class DeeplinksServiceProcessCoordinatingTests: XCTestCase {
    // MARK: - Private Properties

    private let delegate = CoordinatorDelegateMock()
    private let dataSource = CoordinatorDataSourceMock()

    private let scheme = "example://"
    private let parametersConfiguration = DeeplinkParametersConfiguration(
        beginningSymbol: "{",
        endsSymbol: "}",
        optionalSymbol: "?"
    )

    private let factory = DeeplinksServiceFactory()
    private lazy var service = factory.makeDeeplinkService(
        configuration: .init(
            parametersConfiguration: parametersConfiguration,
            appUrlScheme: scheme
        ),
        sources: .init(
            deeplinksProvider: DeeplinksProviderMock(),
            coordinatorDelegate: delegate,
            coordinatorDataSource: dataSource,
            universalDeeplinksDelegate: nil
        )
    )

    private let path = "MockPath"
    private lazy var url = URL(string: scheme + path)!

    // MARK: - Tests for Deeplink Retrieval

    func testProcessWithDismissingOpenedControllers_ExecutingDelegateMethod() throws {
        let delegateMethodHandlingExpectation = XCTestExpectation(description: "Handling delegate method")
        delegate.routeToRootAction = {
            delegateMethodHandlingExpectation.fulfill()
        }
        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: true,
            onExecuting: { .success(.present(viewController: .init(), strategy: .show)) },
            onError: { _ in
                XCTFail("Failed to process the deeplink due to an error.")
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Failed to process the deeplink due to an error.")
        }

        wait(for: [delegateMethodHandlingExpectation], timeout: 5)
    }

    func testProcessWithoutDismissingOpenedControllers_NotExecutingDelegateMethod() throws {
        delegate.routeToRootAction = {
            XCTFail("Failed to process the deeplink due to an error.")
        }
        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { .success(.present(viewController: .init(), strategy: .show)) },
            onError: { _ in
                XCTFail("Failed to process the deeplink due to an error.")
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Failed to process the deeplink due to an error.")
        }
    }

    func testProcessWithPreloader_PresentingPreloader() throws {
        let onFirstPresentExpectation = XCTestExpectation(
            description: "First preloader presentation should be handled."
        )
        let onFirstDismissExpectation = XCTestExpectation(
            description: "First preloader dismissal should be handled."
        )
        let onDismissBeforeSecondPresentExpectation = XCTestExpectation(
            description: "Preloader dismissal should be handled in preparing to present preloader second time."
        )
        let onSecondPresentExpectation = XCTestExpectation(
            description: "Second preloader presentation should be handled."
        )
        let onSecondDismissExpectation = XCTestExpectation(
            description: "Third preloader dismissal should be handled."
        )

        let loader = ViewControllerMock()
        let presenter = ViewControllerMock()
        var onPresentCount = 0
        var onDismissCount = 0

        presenter.onPresent = {
            XCTAssertTrue(loader === $0)
            onPresentCount += 1
            switch onPresentCount {
            case 1:
                onFirstPresentExpectation.fulfill()
            case 2:
                onSecondPresentExpectation.fulfill()
            default:
                XCTFail("Unexpected number of preloader presentations.")
            }
        }

        loader.onDismiss = {
            onDismissCount += 1
            switch onDismissCount {
            case 1:
                onFirstDismissExpectation.fulfill()
            case 2:
                onDismissBeforeSecondPresentExpectation.fulfill()
            case 3:
                onSecondDismissExpectation.fulfill()
            default:
                XCTFail("Unexpected number of preloader dismissals.")
            }
        }

        dataSource.provideLoader = { loader }
        dataSource.providePresenter = { presenter }
        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: true,
            needPopToRoot: false,
            onExecuting: { .success(.present(viewController: .init(), strategy: .show)) },
            onError: { _ in
                XCTFail("Failed to process the deeplink due to an error.")
                return nil
            }
        )

        (0...1).forEach { _ in
            service.process(
                deeplink: deeplinkMock,
                url: url
            ) { _ in
                XCTFail("Failed to process the deeplink due to an error.")
            }
        }

        wait(
            for: [
                onFirstPresentExpectation,
                onFirstDismissExpectation,
                onDismissBeforeSecondPresentExpectation,
                onSecondPresentExpectation,
                onSecondDismissExpectation
            ],
            timeout: 5,
            enforceOrder: true
        )
    }

    func testProcessWithoutPreloader_NotPresentingPreloader() throws {
        let loader = ViewControllerMock()
        let presenter = ViewControllerMock()

        presenter.onPresent = { _ in
            XCTFail("Preloader should not be presented because 'needPreloader' is set to false.")
        }
        loader.onDismiss = {                
            XCTFail("Preloader should not be dismissed because 'needPreloader' is set to false.")

        }

        dataSource.provideLoader = { loader }
        dataSource.providePresenter = { presenter }
        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { .success(.present(viewController: .init(), strategy: .show)) },
            onError: { _ in
                XCTFail("Failed to process the deeplink due to an error.")
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Failed to process the deeplink due to an error.")
        }
    }

    func testProcessShowVC_ShowingVC() throws {
        let showVCExpectation = XCTestExpectation(description: "Expected view controller to be shown.")
        let presenter = ViewControllerMock()
        let viewController = UIViewController()

        presenter.onPresent = { _ in
            XCTFail("View controller should not be presented, 'show' strategy is used.")
        }
        presenter.onShow = {
            XCTAssertTrue(viewController === $0, "Expected the provided view controller to be shown.")
            showVCExpectation.fulfill()
        }
        presenter.onShowDetail = { _ in
            XCTFail("View controller should not be shown with 'showDetail', 'show' strategy is used.")
        }
        dataSource.providePresenter = { presenter }

        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { .success(.present(viewController: viewController, strategy: .show)) },
            onError: { _ in
                XCTFail("Failed to process the deeplink due to an error.")
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Failed to process the deeplink due to an error.")
        }

        wait(for: [showVCExpectation], timeout: 5)
    }

    func testProcessShowDetailVC_ShowingDetailVC() throws {
        let showDetailVCExpectation = XCTestExpectation(description: "Expected detail view controller to be shown.")
        let presenter = ViewControllerMock()
        let viewController = UIViewController()

        presenter.onPresent = { _ in
            XCTFail("View controller should not be presented, 'showDetailViewController' strategy is used.")
        }
        presenter.onShow = { _ in
            XCTFail("View controller should not be shown with 'show', 'showDetailViewController' strategy is used.")
        }
        presenter.onShowDetail = { 
            XCTAssertTrue(viewController === $0, "Expected the provided view controller to be shown in detail mode.")
            showDetailVCExpectation.fulfill()
        }
        dataSource.providePresenter = { presenter }

        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { .success(.present(viewController: viewController, strategy: .showDetailViewController)) },
            onError: { _ in
                XCTFail("Failed to process the deeplink due to an error.")
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Failed to process the deeplink due to an error.")
        }

        wait(for: [showDetailVCExpectation], timeout: 5)
    }

    func testProcessCustomAction_ExecutingCustomAction() throws {
        let customActionExpectation = XCTestExpectation(description: "Expected custom action to be executed.")
        let presenter = ViewControllerMock()

        presenter.onPresent = { _ in
            XCTFail("Custom action should not present a view controller.")
        }
        presenter.onShow = { _ in
            XCTFail("Custom action should not show a view controller.")
        }
        presenter.onShowDetail = { _ in
            XCTFail("Custom action should not show detail view controller.")
        }
        dataSource.providePresenter = { presenter }

        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { .success(.custom({ customActionExpectation.fulfill() })) },
            onError: { _ in
                XCTFail("Failed to process the deeplink due to an error.")
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Failed to process the deeplink due to an error.")
        }

        wait(for: [customActionExpectation], timeout: 5)
    }

    func testProcessCustomActionWithPresenter_ExecutingCustomActionWithPresenter() throws {
        let customActionWithPresenterExpectation = XCTestExpectation(
            description: "Expected custom action with presenter to be executed."
        )
        let presenter = ViewControllerMock()

        presenter.onPresent = { _ in
            XCTFail("Custom action should not present a view controller.")
        }
        presenter.onShow = { _ in
            XCTFail("Custom action should not show a view controller.")
        }
        presenter.onShowDetail = { _ in
            XCTFail("Custom action should not show detail view controller.")
        }
        dataSource.providePresenter = { presenter }

        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: {
                .success(
                    .customWithPresenter({
                        XCTAssertTrue(presenter === $0, "Expected the presenter to be passed to the custom action.")
                        customActionWithPresenterExpectation.fulfill()
                    })
                )
            },
            onError: { _ in
                XCTFail("Failed to process the deeplink due to an error.")
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Failed to process the deeplink due to an error.")
        }

        wait(for: [customActionWithPresenterExpectation], timeout: 5)
    }

    func testProcessErrorInDeeplinkWithoutPreloader_ExecutingOnError() throws {
        let errorHandlingExpectation = XCTestExpectation(description: "Expected error handling closure to be called.")
        let deeplinkErrorExpectation = XCTestExpectation(description: "Expected deeplink error handling closure to be called.")
        let expectedError = NSError(domain: "some", code: -1)
        let presenter = ViewControllerMock()

        presenter.onPresent = { _ in
            XCTFail("Presenter should not present a view controller due to an error.")
        }
        presenter.onShow = { _ in
            XCTFail("Presenter should not show a view controller due to an error.")
        }
        presenter.onShowDetail = { _ in
            XCTFail("Presenter should not show detail view controller due to an error.")
        }
        dataSource.providePresenter = { presenter }

        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { .failure(expectedError) },
            onError: {
                guard case .failedToHandleDeeplink(let error) = $0 else {
                    XCTFail("Unexpected error type in deeplink error handling.")
                    return nil
                }
                XCTAssertEqual(expectedError, error as NSError, "The error should match the expected error.")
                deeplinkErrorExpectation.fulfill()
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) {
            guard case .failedToHandleDeeplink(let error) = $0 else {
                XCTFail("Unexpected error type in deeplink error handling.")
                return
            }
            XCTAssertTrue(expectedError === error as NSError)
            errorHandlingExpectation.fulfill()
            return
        }

        wait(for: [deeplinkErrorExpectation, errorHandlingExpectation], timeout: 5)
    }

    func testProcessErrorInDeeplinkWithPreloader_ExecutingOnError() throws {
        let loaderPresentationExpectation = XCTestExpectation(
            description: "Expected loader view controller to be presented."
        )
        let loaderDismissalExpectation = XCTestExpectation(
            description: "Expected loader view controller to be dismissed."
        )
        let deeplinkErrorHandlingExpectation = XCTestExpectation(
            description: "Expected deeplink error handling closure to be called."
        )
        let deeplinkProcessingErrorExpectation = XCTestExpectation(
            description: "Expected deeplink processing error closure to be called."
        )

        let expectedError = NSError(domain: "some", code: -1)
        let presenter = ViewControllerMock()
        let loader = ViewControllerMock()

        presenter.onPresent = {
            XCTAssertTrue(loader === $0, "Presenter should present the loader view controller.")
            loaderPresentationExpectation.fulfill()
        }
        loader.onDismiss = {
            loaderDismissalExpectation.fulfill()
        }
        presenter.onShow = { _ in
            XCTFail("Presenter should not show a view controller due to an error.")
        }
        presenter.onShowDetail = { _ in
            XCTFail("Presenter should not show a detail view controller due to an error.")
        }
        dataSource.providePresenter = { presenter }
        dataSource.provideLoader = { loader }

        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: true,
            needPopToRoot: false,
            onExecuting: { .failure(expectedError) },
            onError: {
                guard case .failedToHandleDeeplink(let error) = $0 else {
                    XCTFail("Unexpected error type in deeplink error handling.")
                    return nil
                }
                XCTAssertEqual(expectedError, error as NSError, "The error should match the expected error.")
                deeplinkErrorHandlingExpectation.fulfill()
                return nil
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) {
            guard case .failedToHandleDeeplink(let error) = $0 else {
                XCTFail("Wrong error")
                return
            }
            XCTAssertTrue(expectedError === error as NSError)
            deeplinkProcessingErrorExpectation.fulfill()
            return
        }

        wait(
            for: [
                loaderPresentationExpectation,
                loaderDismissalExpectation,
                deeplinkErrorHandlingExpectation,
                deeplinkProcessingErrorExpectation
            ],
            timeout: 5,
            enforceOrder: true
        )
    }

    func testProcessErrorInDeeplinkWithErrorAction_ExecutingOnError() throws {
        let customActionExpectation = XCTestExpectation(
            description: "Expected custom action to be executed on deeplink error."
        )
        let expectedError = NSError(domain: "some", code: -1)
        let presenter = ViewControllerMock()

        presenter.onPresent = { _ in
            XCTFail("Presenter should not present a view controller due to an error.")
        }
        presenter.onShow = { _ in
            XCTFail("Presenter should not show a view controller due to an error.")
        }
        presenter.onShowDetail = { _ in
            XCTFail("Presenter should not show a detail view controller due to an error.")
        }
        dataSource.providePresenter = { presenter }

        let deeplinkMock = DeeplinkMockWithAction(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { .failure(expectedError) },
            onError: { _ in .custom({ customActionExpectation.fulfill() }) }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in }

        wait(for: [customActionExpectation], timeout: 5)
    }
}
