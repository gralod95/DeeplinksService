import XCTest
@testable import DeeplinksService

final class DeeplinksServiceGetDeeplinkTests: XCTestCase {
    // MARK: - Private Properties

    private let scheme = "example://"
    private let parametersConfiguration = DeeplinkParametersConfiguration(
        beginningSymbol: "{",
        endsSymbol: "}",
        optionalSymbol: "?"
    )

    private let providerMock = DeeplinksProviderMock()
    private let universalDeeplinksDelegate = UniversalDeeplinksDelegateMock()

    private let factory = DeeplinksServiceFactory()
    private lazy var service = factory.makeDeeplinkService(
        configuration: .init(
            parametersConfiguration: parametersConfiguration,
            appUrlScheme: scheme
        ),
        sources: .init(
            deeplinksProvider: providerMock,
            coordinatorDelegate: CoordinatorDelegateMock(),
            coordinatorDataSource: CoordinatorDataSourceMock(),
            universalDeeplinksDelegate: nil
        )
    )

    private let path = "MockPath"
    private lazy var url = URL(string: scheme + path)!

    // MARK: - Tests for Deeplink Retrieval

    func testGetDeeplinkWhenDeeplinkArrayIsEmpty_ReturnsNil() throws {
        providerMock.mocks = []

        XCTAssertNil(try? service.getDeeplink(url: url))
    }

    func testGetDeeplink_ReturnsNil() throws {
        providerMock.mocks = (0...100).map {
            DeeplinkMock<EmptyDeeplinkParameters>(
                path: .paths([path + "\($0)"]),
                needPreloader: false,
                needPopToRoot: false
            )
        }

        XCTAssertNil(try? service.getDeeplink(url: url))
    }

    func testGetDeeplinkWhenSchemeIsIncorrect_ThrowsError() throws {
        let scheme = "exampla://"
        let url = URL(string: scheme + path)!

        providerMock.mocks = [
            DeeplinkMock<EmptyDeeplinkParameters>(
                path: .paths([path]),
                needPreloader: false,
                needPopToRoot: false
            )
        ]

        XCTAssertNil(try? service.getDeeplink(url: url))
    }

    func testGetDeeplinkWhenPathIsIncorrect_ThrowsError() throws {
        let path = "(*abc"
        providerMock.mocks = [
            DeeplinkMock<EmptyDeeplinkParameters>(
                path: .paths([path]),
                needPreloader: false,
                needPopToRoot: false
            )
        ]

        do {
            _ = try service.getDeeplink(url: url)
            XCTFail("Deeplink parsing error didn't ocupaide")
        } catch {
            guard case .pathIsIncorrect(let errorPath, let error) = error as? DeeplinkProcessingError else {
                XCTFail("Expected pathIsIncorrect error, but received: \(error)")

                return
            }
            
            XCTAssertEqual(errorPath, .paths([path]), "Incorrect error paths")
            XCTAssertEqual((error as NSError).code, 2048, "Incorrect error code")
            XCTAssertEqual((error as NSError).domain, "NSCocoaErrorDomain", "Incorrect error domain")
        }
    }

    func testGetDeeplinkWithValidUniversalLink_ReturnsDeeplink() throws {
        let universalLinkPath = "5Reeerg"
        let universalLinkMock = URL(string: scheme + universalLinkPath)!

        let deeplinkMock = DeeplinkMock<EmptyDeeplinkParameters>(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false
        )

        let serviceWithUniversalLink = factory.makeDeeplinkService(
            configuration: .init(
                parametersConfiguration: parametersConfiguration,
                appUrlScheme: scheme
            ),
            sources: .init(
                deeplinksProvider: providerMock,
                coordinatorDelegate: CoordinatorDelegateMock(),
                coordinatorDataSource: CoordinatorDataSourceMock(),
                universalDeeplinksDelegate: universalDeeplinksDelegate
            )
        )

        universalDeeplinksDelegate.map = [universalLinkMock: url]
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try serviceWithUniversalLink.getDeeplink(url: universalLinkMock) else {
                XCTFail("Failed: No deeplink found for the URL: \(universalLinkMock)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<EmptyDeeplinkParameters>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )

        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    // MARK: - Tests for Regex and Parameters

    func testGetDeeplinkWithRegexPattern_ReturnsDeeplink() throws {
        let regex = "MockPath"
        let deeplinkMock = DeeplinkMock<EmptyDeeplinkParameters>(
            path: .regularExpression(regex),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: url) else {
                XCTFail("Failed: No deeplink found for the URL: \(url)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<EmptyDeeplinkParameters>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithPath_ReturnsDeeplink() throws {
        let deeplinkMock = DeeplinkMock<EmptyDeeplinkParameters>(
            path: .paths([path]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: url) else {
                XCTFail("Failed: No deeplink found for the URL: \(url)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<EmptyDeeplinkParameters>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithSeveralPaths_ReturnsDeeplink() throws {
        let paths = (0...10).map { path + ($0 == .zero ? "" : "\($0)")}
        let deeplinkMock = DeeplinkMock<EmptyDeeplinkParameters>(
            path: .paths(paths),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: url) else {
                XCTFail("Failed: No deeplink found for the URL: \(url)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<EmptyDeeplinkParameters>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithParameterInPath_ReturnsDeeplink() throws {
        let pathWithParameter = "MockPath?{}"
        let urlPathWithParameter = "MockPath?sample=some"
        let urlWithParameter = URL(string: scheme + urlPathWithParameter)!

        let deeplinkMock = DeeplinkMock<DeeplinkParametersMock>(
            path: .paths([pathWithParameter]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: urlWithParameter) else {
                XCTFail("Failed: No deeplink found for the URL: \(urlWithParameter)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<DeeplinkParametersMock>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithParameterAsPath_ReturnsDeeplink() throws {
        let pathWithParameterAsPath = "{sample}"
        let urlPathWithParameterAsPath = "sample"
        let urlWithParameterAsPath = URL(string: scheme + urlPathWithParameterAsPath)!

        let deeplinkMock = DeeplinkMock<DeeplinkParametersMock>(
            path: .paths([pathWithParameterAsPath]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: urlWithParameterAsPath) else {
                XCTFail("Failed: No deeplink found for the URL: \(urlWithParameterAsPath)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<DeeplinkParametersMock>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithParameterAsPathItem_ReturnsDeeplink() throws {
        let pathWithParameterAsPathItem = "MockPath/{sample}"
        let urlPathWithParameterAsPathItem = "MockPath/sample"
        let urlWithParameterAsPathItem = URL(string: scheme + urlPathWithParameterAsPathItem)!

        let deeplinkMock = DeeplinkMock<DeeplinkParametersMock>(
            path: .paths([pathWithParameterAsPathItem]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: urlWithParameterAsPathItem) else {
                XCTFail("Failed: No deeplink found for the URL: \(urlWithParameterAsPathItem)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<DeeplinkParametersMock>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithSeveralParameters_ReturnsDeeplink() throws {
        let pathWithSeveralParameters = "MockPath?{sample}&{sample1}"
        let urlPathWithSeveralParameters = "MockPath?sample=sample&sample1=sample1"
        let urlWithSeveralParameters = URL(string: scheme + urlPathWithSeveralParameters)!

        let deeplinkMock = DeeplinkMock<DeeplinkParametersMock>(
            path: .paths([pathWithSeveralParameters]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: urlWithSeveralParameters) else {
                XCTFail("Failed: No deeplink found for the URL: \(urlWithSeveralParameters)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<DeeplinkParametersMock>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithIncorrectParameterInPath_ReturnsError() throws {
        let pathWithWrongParameter = "MockPath{sample}"
        let urlPathWithWrongParameter = "MockPath?sample=sample"
        let urlWithWrongParameter = URL(string: scheme + urlPathWithWrongParameter)!
        let parameterInError = "h{sample}"
        let deeplinkMock = DeeplinkMock<DeeplinkParametersMock>(
            path: .paths([pathWithWrongParameter]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            _ = try service.getDeeplink(url: urlWithWrongParameter)

            XCTFail("Failed: No error of wrong parameters")
        } catch {
            guard case .invalidParameterPosition(let parameter) = error as? DeeplinkProcessingError else {
                XCTFail("Wrong error: \(error)")
                return
            }
            XCTAssertEqual(
                parameter,
                parameterInError,
                "The parameter in error does not match the expected incorrect parameter."
            )
        }
    }

    func testGetDeeplinkWithOptionalParameterInPathAndNoParameterInUrl_ReturnsDeeplink() throws {
        let pathWithOptionalParameters = "MockPath?{sample?}"

        let deeplinkMock = DeeplinkMock<DeeplinkParametersMock>(
            path: .paths([pathWithOptionalParameters]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: url) else {
                XCTFail("Failed: No deeplink found for the URL: \(url)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<DeeplinkParametersMock>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithOptionalParameterInPathAndParameterInUrl_ReturnsDeeplink() throws {
        let pathWithOptionalParameters = "MockPath?{sample?}"
        let urlPathWithParameter = "MockPath?sample=sample"
        let urlWithParameter = URL(string: scheme + urlPathWithParameter)!

        let deeplinkMock = DeeplinkMock<DeeplinkParametersMock>(
            path: .paths([pathWithOptionalParameters]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: urlWithParameter) else {
                XCTFail("Failed: No deeplink found for the URL: \(urlWithParameter)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<DeeplinkParametersMock>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }

    func testGetDeeplinkWithParameterInTheMiddleOfPath_ReturnsDeeplink() throws {
        let pathWithParametersInTheMiddle = "MockPath?{sample?}/Mock2"
        let urlPathWithParametersInTheMiddle = "MockPath?sample=sample/Mock2"
        let urlWithParametersInTheMiddle = URL(string: scheme + urlPathWithParametersInTheMiddle)!

        let deeplinkMock = DeeplinkMock<DeeplinkParametersMock>(
            path: .paths([pathWithParametersInTheMiddle]),
            needPreloader: false,
            needPopToRoot: false
        )
        providerMock.mocks = [deeplinkMock]

        do {
            guard let deeplink = try service.getDeeplink(url: urlWithParametersInTheMiddle) else {
                XCTFail("Failed: No deeplink found for the URL: \(urlWithParametersInTheMiddle)")
                return
            }

            XCTAssertTrue(
                deeplinkMock === (deeplink as? DeeplinkMock<DeeplinkParametersMock>),
                "Expected the returned deeplink to be \(deeplinkMock), but got a different instance."
            )
        } catch {
            XCTFail("Deeplink processing error occurred: \(error)")
        }
    }
}
