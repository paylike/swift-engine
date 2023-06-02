import XCTest
import PaylikeClient

@testable import PaylikeEngine

final class PaylikeEngineCheckTests: XCTestCase {
    let testFunc = "Test func"
    
    func test_PaylikeEngine_checkValidState_valid() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        XCTAssertNoThrow(try engine.checkValidState(valid: .WAITING_FOR_INPUT, callerFunc: testFunc))
    }
    func test_PaylikeEngine_checkValidState_invalid() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        do {
            XCTAssertNoThrow(try engine.checkValidState(valid: .WAITING_FOR_INPUT, callerFunc: testFunc))
            try engine.checkValidState(valid: .ERROR, callerFunc: testFunc)
        } catch {
            let errorString = (error as! EngineError).errorDescription
            let expectedErrorString = EngineError.InvalidEngineState(caller: testFunc, actual: .WAITING_FOR_INPUT, expected: .ERROR).errorDescription
            XCTAssertEqual(errorString, expectedErrorString)
        }
    }
    
    func test_PaylikeEngine_isPaymentRepositoryInitialised_valid() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        engine.repository = EngineReposity(paymentRepository: CreatePaymentRequest(merchantID: PaymentIntegration(merchantId: merchantId)))
        XCTAssertNoThrow(try engine.isPaymentRepositoryInitialised())
    }
    func test_PaylikeEngine_isPaymentRepositoryInitialised_invalid() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        do {
            try engine.isPaymentRepositoryInitialised()
        } catch {
            let errorString = (error as! EngineError).errorDescription
            let expectedErrorString = EngineError.PaymentRespositoryIsNotInitialised.errorDescription
            XCTAssertEqual(errorString, expectedErrorString)
        }
    }
    
    func test_PaylikeEngine_areEssentialPaymentRepositoryFieldsAdded_valid_applePay() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        let applePayToken = "token"
        engine.repository = EngineReposity(paymentRepository: CreatePaymentRequest(
            with: ApplePayToken(token: applePayToken),
            merchantID: PaymentIntegration(merchantId: merchantId))
        )
        
        XCTAssertNoThrow(try engine.areEssentialPaymentRepositoryFieldsAdded())
    }
    func test_PaylikeEngine_areEssentialPaymentRepositoryFieldsAdded_valid_cardData() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        let cardNumberToken = "token"
        let cardCvcToken = "token"
        engine.repository = EngineReposity(paymentRepository: CreatePaymentRequest(
            with: PaymentCard(
                number: CardNumberToken(token: cardNumberToken),
                code: CardSecurityCodeToken(token: cardCvcToken),
                expiry: try! CardExpiry(month: 10, year: 99)
            ),
            merchantID: PaymentIntegration(merchantId: merchantId))
        )
        XCTAssertNoThrow(try engine.areEssentialPaymentRepositoryFieldsAdded())
    }
    func test_PaylikeEngine_areEssentialPaymentRepositoryFieldsAdded_invalid_none() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        engine.repository = EngineReposity(paymentRepository: CreatePaymentRequest(merchantID: PaymentIntegration(merchantId: merchantId)))
        do {
            try engine.areEssentialPaymentRepositoryFieldsAdded()
        } catch {
            let errorString = (error as! EngineError).errorDescription
            let expectedErrorString = EngineError.EssentialPaymentRepositoryDataFailure(hasBoth: false).errorDescription
            XCTAssertEqual(errorString, expectedErrorString)
        }
    }
    func test_PaylikeEngine_areEssentialPaymentRepositoryFieldsAdded_invalid_bothExist() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        let applePayToken = "token"
        let cardNumberToken = "token"
        let cardCvcToken = "token"
        engine.repository = EngineReposity(paymentRepository: CreatePaymentRequest(
            with: PaymentCard(
                number: CardNumberToken(token: cardNumberToken),
                code: CardSecurityCodeToken(token: cardCvcToken),
                expiry: try! CardExpiry(month: 10, year: 99)
            ),
            merchantID: PaymentIntegration(merchantId: merchantId))
        )
        engine.repository.paymentRepository?.applepay = ApplePayToken(token: applePayToken)
        do {
            try engine.areEssentialPaymentRepositoryFieldsAdded()
        } catch {
            let errorString = (error as! EngineError).errorDescription
            let expectedErrorString = EngineError.EssentialPaymentRepositoryDataFailure(hasBoth: true).errorDescription
            XCTAssertEqual(errorString, expectedErrorString)
        }
    }
    
    func test_PaylikeEngine_isNumberOfHintsRight_valid() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        engine.repository = EngineReposity(paymentRepository: CreatePaymentRequest(merchantID: PaymentIntegration(merchantId: merchantId)))
        XCTAssertNoThrow(try engine.isNumberOfHintsRight())
        
        engine.state = .WEBVIEW_CHALLENGE_STARTED
        let numberOfHints = EngineState.getNumberOfExpectedHints(state: engine.state)
        engine.repository.paymentRepository?.hints = [String](repeating: "hint", count: numberOfHints)
        XCTAssertNoThrow(try engine.isNumberOfHintsRight())
    }
    
    func test_PaylikeEngine_isNumberOfHintsRight_invalid() {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
        engine.repository = EngineReposity(paymentRepository: CreatePaymentRequest(merchantID: PaymentIntegration(merchantId: merchantId)))
        engine.state = .WEBVIEW_CHALLENGE_STARTED
        do {
            try engine.isNumberOfHintsRight()
        } catch {
            let errorString = (error as! EngineError).errorDescription
            let actualHintNumber = engine.repository.paymentRepository!.hints.count
            let expectedHintNumber = EngineState.getNumberOfExpectedHints(state: engine.state)
            let expectedErrorString = EngineError.WrongAmountOfHints(actual: actualHintNumber, expected: expectedHintNumber).errorDescription
            XCTAssertEqual(errorString, expectedErrorString)
        }
    }

}
