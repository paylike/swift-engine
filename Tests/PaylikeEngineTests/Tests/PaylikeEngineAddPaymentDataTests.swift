import AnyCodable
import PaylikeLuhn
import PaylikeRequest
import PaylikeClient
import XCTest

@testable import PaylikeEngine

final class PaylikeEngineAddPaymentDataTests: XCTestCase {
    
    private static let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
    private static var mockedPaylikeClient = PaylikeClient(clientID: "mocked")
    private static var mockPaylikeServer = MockHTTPServer()
    
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
    
    func test_PaylikeEngine_addEssentialPaymentData_withApplePayToken() {
        let engine = Self.engine
        engine.resetEngine()
        let expectation = expectation(description: "Value should be received")
        XCTAssertNotNil(engine.repository)
        XCTAssertNil(engine.repository.paymentRepository)
        Task {
            await engine.addEssentialPaymentData(applePayToken: Self.applePayToken)
            guard engine.internalState != .ERROR else {
                XCTFail("Should not get error: \(engine.internalError!.message)")
                return
            }
            XCTAssertNotNil(engine.repository.paymentRepository)
            XCTAssertNotNil(engine.repository.paymentRepository?.integration)
            XCTAssertNotNil(engine.repository.paymentRepository?.applepay)
            let expectedToken = Self.tokenized + "+" + Self.applePayToken
            let actualToken = engine.repository.paymentRepository?.applepay?.token
            XCTAssertEqual(actualToken, expectedToken)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test_PaylikeEngine_addEssentialPaymentData_withCardData() {
        let engine = Self.engine
        engine.resetEngine()
        let expectation = expectation(description: "Value should be received")
        XCTAssertNotNil(engine.repository)
        XCTAssertNil(engine.repository.paymentRepository)
        Task {
            await engine.addEssentialPaymentData(
                cardNumber: Self.cardNumber,
                cvc: Self.cardSecurityCode,
                month: Self.cardExpiryMonth,
                year: Self.cardExpiryYear
            )
            guard engine.internalState != .ERROR else {
                XCTFail("Should not get error: \(engine.internalError!.message)")
                return
            }
            XCTAssertNotNil(engine.repository.paymentRepository)
            XCTAssertNotNil(engine.repository.paymentRepository?.integration)
            XCTAssertNotNil(engine.repository.paymentRepository?.card)
            let expectedCardNumberToken = Self.tokenized + "+" + Self.cardNumber
            let actualCardNumberToken = engine.repository.paymentRepository?.card?.number.token
            XCTAssertEqual(actualCardNumberToken, expectedCardNumberToken)
            let expectedCardCVCToken = Self.tokenized + "+" + Self.cardSecurityCode
            let actualCardCVCToken = engine.repository.paymentRepository?.card?.code.token
            XCTAssertEqual(actualCardCVCToken, expectedCardCVCToken)
            XCTAssertEqual(engine.repository.paymentRepository?.card?.expiry.month, Self.cardExpiryMonth)
            XCTAssertEqual(engine.repository.paymentRepository?.card?.expiry.year, Self.cardExpiryYear)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test_PaylikeEngine_addEssentialPaymentData_withCardData_invalid() {
        let engine = Self.engine
        engine.resetEngine()
        let expectation = expectation(description: "Value should be received")
        XCTAssertNotNil(engine.repository)
        XCTAssertNil(engine.repository.paymentRepository)
        let invalidMonth = 13
        Task {
            await engine.addEssentialPaymentData(
                cardNumber: Self.cardNumber,
                cvc: Self.cardSecurityCode,
                month: invalidMonth,
                year: Self.cardExpiryYear
            )
            XCTAssertNotNil(engine.repository)
            XCTAssertNil(engine.repository.paymentRepository)
            XCTAssertEqual(engine.internalState, .ERROR)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func test_PaylikeEngine_addDescriptionPaymentData() {
        let engine = Self.engine
        engine.resetEngine()
        XCTAssertNotNil(engine.repository)
        XCTAssertNil(engine.repository.paymentRepository)
        let amount = PaymentAmount(currency: .AED, value: 11, exponent: 0)
        let plan = [PaymentPlan(amount: amount, scheduled: Date())]
        let unplanned = PaymentUnplanned(costumer: true)
        let test = PaymentTest()
        engine.addDescriptionPaymentData(paymentAmount: amount,
                                         paymentPlanDataList: plan,
                                         paymentUnplannedData: unplanned,
                                         paymentTestData: test
        )
        XCTAssertNotNil(engine.repository.paymentRepository?.amount)
        XCTAssertNotNil(engine.repository.paymentRepository?.plan)
        XCTAssertNotNil(engine.repository.paymentRepository?.unplanned)
        XCTAssertNotNil(engine.repository.paymentRepository?.test)
        XCTAssertEqual(engine.repository.paymentRepository?.amount, amount)
        XCTAssertEqual(engine.repository.paymentRepository?.plan![0].amount, plan[0].amount)
        XCTAssertEqual(engine.repository.paymentRepository?.unplanned?.constumer, unplanned.constumer)
    }
    
    func test_PaylikeEngine_addAdditionalData() {
        let engine = Self.engine
        engine.resetEngine()
        XCTAssertNotNil(engine.repository)
        XCTAssertNil(engine.repository.paymentRepository)
        let text = "text"
        struct CustomData: Encodable {
            let string = "string"
            let array = [0, 1, 2]
        }
        let customData = CustomData()
        engine.addAdditionalPaymentData(textData: text, customData: AnyEncodable(customData))
        XCTAssertNotNil(engine.repository.paymentRepository?.text)
        XCTAssertNotNil(engine.repository.paymentRepository?.custom)
        XCTAssertEqual(engine.repository.paymentRepository?.text, text)
    }
    
    func test_PaylikeEngine_resetEngine() {
        let engine = Self.engine
        engine.resetEngine()
        let expectation = expectation(description: "Value should be received")

        XCTAssertNotNil(engine.repository)
        XCTAssertNil(engine.repository.paymentRepository)
        
        let amount = PaymentAmount(currency: .AED, value: 11, exponent: 0)
        let plan = [PaymentPlan(amount: amount, scheduled: Date())]
        let unplanned = PaymentUnplanned(costumer: true)
        let test = PaymentTest()
        engine.addDescriptionPaymentData(paymentAmount: amount,
                                         paymentPlanDataList: plan,
                                         paymentUnplannedData: unplanned,
                                         paymentTestData: test
        )
        let invalidMonth = 13
        Task {
            await engine.addEssentialPaymentData(
                cardNumber: Self.cardNumber,
                cvc: Self.cardSecurityCode,
                month: invalidMonth,
                year: Self.cardExpiryYear
            )
            XCTAssertNotNil(engine.repository)
            XCTAssertNotNil(engine.repository.paymentRepository)
            XCTAssertEqual(engine.internalState, .ERROR)
            XCTAssertNotNil(engine.error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        engine.resetEngine()
        
        XCTAssertNotNil(engine.repository)
        XCTAssertNil(engine.repository.paymentRepository)
        XCTAssertNil(engine.repository.htmlRepository)
        XCTAssertNil(engine.repository.authorizationId)
        XCTAssertNil(engine.repository.transactionId)
        XCTAssertEqual(engine.internalState, .WAITING_FOR_INPUT)
        XCTAssertNil(engine.internalError)
    }
}
