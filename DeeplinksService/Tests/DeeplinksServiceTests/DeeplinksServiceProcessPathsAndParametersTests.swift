//
//  DeeplinksServiceProcessTests.swift
//  
//
//  Created by Odinokov G. A. on 10.09.2024.
//

import XCTest
@testable import DeeplinksService

final class DeeplinksServiceProcessPathsAndParametersTests: XCTestCase {
    // MARK: - Private Properties

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
            coordinatorDelegate: CoordinatorDelegateMock(),
            coordinatorDataSource: CoordinatorDataSourceMock(),
            universalDeeplinksDelegate: nil
        )
    )

    private let path = "MockPath/Mock1/Mock2"
    private lazy var url = URL(string: scheme + path)!

    private let pathWithParameters = "MockPath/Mock1/Mock2?{mock}"
    private lazy var urlWithParameters = URL(string: scheme + "MockPath/Mock1/Mock2?sample_parameter=mock")!

    // MARK: - Tests for Deeplink Retrieval

    func testProcessDeeplinkWithNoParameters_ExpectationFulfill() throws {
        let actionExpectation = XCTestExpectation(
            description: "Expected the deeplink execution to be fulfilled without parameters."
        )
        let deeplinkMock = DeeplinkMock<EmptyDeeplinkParameters>(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: {
                actionExpectation.fulfill()
            },
            onError: {
                XCTFail("Deeplink processing failed with an unexpected error.")
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Deeplink processing resulted in an unexpected error.")
        }

        wait(for: [actionExpectation], timeout: 5)
    }

    func testProcessDeeplinkWithPathItems_ExpectationFulfill() throws {
        let actionExpectation = XCTestExpectation(
            description: "Expected deeplink execution to fulfill with the correct path items."
        )
        let expectedPathItems = ["MockPath", "Mock1", "Mock2"]

        let deeplinkMock = DeeplinkWithPathItemsAndParametersMock<EmptyDeeplinkParameters>(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { pathItems, parameters in
                XCTAssertEqual(
                    pathItems,
                    expectedPathItems,
                    "The path items received do not match the expected values."
                )
                actionExpectation.fulfill()
            },
            onError: {
                XCTFail("Deeplink processing failed with an unexpected error.")
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: url
        ) { _ in
            XCTFail("Deeplink processing resulted in an unexpected error.")
        }

        wait(for: [actionExpectation], timeout: 5)
    }

    func testProcessDeeplinkWithPathItemsAndParameters_ExpectationFulfill() throws {
        let executionExpectation = XCTestExpectation(
            description: "Expected deeplink execution to fulfill with correct path items and parameters."
        )
        let expectedPathItems = ["MockPath", "Mock1", "Mock2"]

        let deeplinkMock = DeeplinkWithPathItemsAndParametersMock<DeeplinkParametersMock>(
            path: .paths([pathWithParameters]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { pathItems, _ in
                XCTAssertEqual(
                    pathItems,
                    expectedPathItems,
                    "The path items received do not match the expected values."
                )
                executionExpectation.fulfill()
            },
            onError: {
                XCTFail("Deeplink processing failed with an unexpected error.")
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: urlWithParameters
        ) { _ in
            XCTFail("Deeplink processing resulted in an unexpected error.")
        }

        wait(for: [executionExpectation], timeout: 5)
    }

    func testProcessDeeplinkWithPathItemsAndIncorrectParameters_ThrowsError() throws {
        let urlWithIncorrectParameters = URL(string: scheme + "MockPath/Mock1/Mock2?sample_p=mock")!
        let deeplinkErrorExpectation = XCTestExpectation(
            description: "Expecting deeplink model to handle error during execution"
        )
        let closureErrorExpectation = XCTestExpectation(
            description: "Expecting closure to handle error during execution"
        )
        let deeplinkMock = DeeplinkWithPathItemsAndParametersMock<DeeplinkParametersMock>(
            path: .paths([pathWithParameters]),
            needPreloader: false,
            needPopToRoot: false,
            onExecuting: { pathItems, parameters in
                XCTFail("Expected error during deeplink execution due to incorrect parameters, but execution proceeded.")
            },
            onError: {
                deeplinkErrorExpectation.fulfill()
            }
        )

        service.process(
            deeplink: deeplinkMock,
            url: urlWithIncorrectParameters
        ) { error in
            if case .parsingParametersFailed(let error) = error {
                XCTAssertEqual((error as NSError).domain, NSCocoaErrorDomain, "Expected error domain does not match.")
                XCTAssertEqual((error as NSError).code, 4865, "Expected error code does not match.")
            } else {
                XCTFail("Expected .parsingParametersFailed error, but got a different error: \(error)")
            }
            closureErrorExpectation.fulfill()
        }

        wait(for: [deeplinkErrorExpectation, closureErrorExpectation], timeout: 5)
    }
}
