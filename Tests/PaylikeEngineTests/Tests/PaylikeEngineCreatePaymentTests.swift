import AnyCodable
import Combine
import PaylikeLuhn
import PaylikeRequest
import PaylikeClient
import XCTest

@testable import PaylikeEngine

final class PaylikeEngineCreatePaymentTests: XCTestCase {
    
    private static let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
    private static var mockedPaylikeClient = PaylikeClient(clientID: "mocked")
    static var mockPaylikeServer = MockHTTPServer()
    var cancellables: Set<AnyCancellable> = []

    private static let applePayToken = "applePayToken"
    private static let cardNumber = "4100000000000000"
    private static let cardSecurityCode = "111"
    private static let cardExpiryMonth = 10
    private static let cardExpiryYear = 2099
    private static let tokenized = "tokenized"
    
    public class override func setUp() {
        /*
         * Mock the internal HTTP client and the Client implementation in the engine
         */
        mockedPaylikeClient.httpClient = MockHTTPClient(MockPort)
        engine.client = mockedPaylikeClient
        engine.webViewModel = MockedWebViewModel(engine: engine)
        
        /*
         * Initializing client and HTTPclient without logging. We do not log in tests
         */
        engine.setLoggignMode(newMode: .RELEASE)
        
        /*
         * Mock server start
         */
        do {
            try mockPaylikeServer.start(MockPort)
        } catch {
            XCTFail("Server start error: \(error)")
        }
    }

    public class override func tearDown() {
        mockPaylikeServer.stop()
    }

    func test_PaylikeEngine_startPayment_withCardData() {
        let engine = Self.engine
        engine.resetEngine()
        let initExpectation = expectation(description: "Data should be added")
        Task {
            await engine.addEssentialPaymentData(
                cardNumber: Self.cardNumber,
                cvc: Self.cardSecurityCode,
                month: Self.cardExpiryMonth,
                year: Self.cardExpiryYear
            )
            engine.addDescriptionPaymentData(
                paymentAmount: PaymentAmount(currency: .HUF, value: 1, exponent: 0),
                paymentTestData: PaymentTest()
            )
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 10)
        
        let challengeStartedExpectation = expectation(description: "Engine state should be WEBVIEW_CHALLENGE_STARTED")
        let interactionStartedExpectation = expectation(description: "Engine state should be WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED")
        let successExpectation = expectation(description: "Engine state should be SUCCESS")

        engine.$_state.sink(receiveValue: { state in
            switch state {
                case .WAITING_FOR_INPUT:
                    break
                case .WEBVIEW_CHALLENGE_STARTED:
                    challengeStartedExpectation.fulfill()
                case .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED:
                    interactionStartedExpectation.fulfill()
                case .SUCCESS:
                    successExpectation.fulfill()
                case .ERROR:
                    XCTFail("Should not step in ERROR state")
            }
        }).store(in: &cancellables)
        
        
        Task {
            await engine.startPayment()
        }
        wait(for: [challengeStartedExpectation], timeout: 10)
        XCTAssertEqual(engine.state, .WEBVIEW_CHALLENGE_STARTED)
        XCTAssertEqual(engine.repository.paymentRepository?.hints.count, 3)
        
        wait(for: [interactionStartedExpectation], timeout: 10)
        XCTAssertEqual(engine.state, .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED)
        XCTAssertEqual(engine.repository.paymentRepository?.hints.count, 7)
        
        wait(for: [successExpectation], timeout: 10)
        XCTAssertEqual(engine.state, .SUCCESS)
        XCTAssertEqual(engine.repository.paymentRepository?.hints.count, 8)
        XCTAssertNotNil(engine.repository.authorizationId)
        XCTAssertEqual(engine.repository.authorizationId, Self.mockPaylikeServer.authorizationId)
        
        engine.resetEngine()
        XCTAssertNil(engine.repository.authorizationId)
        XCTAssertNil(engine.repository.htmlRepository)
        XCTAssertNil(engine.repository.transactionId)
        XCTAssertNil(engine.repository.paymentRepository)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
    }
}

// WAITING_FOR_INPUT
// startPayment
// client.requestPayment
// receive                                                  3 hints continuously
// save hints at once
// save html
// WEBVIEW_CHALLENGE_STARTED
// create webView
// startPayment finished
// load html
// webView throws                                           3
// save hints at once
// continuePayment
// client.requestPayment
// receive                                                  1 hint
// save hint
// save html
// WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED
// load html
// continuePayment finished
// user interaction
// webView throw                                            1 hint (tds-challenge-terminate)
// save hint
// finishPayment
// client.requestPayment
// authorizationID
// SUCCESS
// finishPayment finished
