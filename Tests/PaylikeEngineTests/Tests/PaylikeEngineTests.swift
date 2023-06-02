import XCTest

@testable import PaylikeEngine

final class PaylikeEngineTests: XCTestCase {
    var engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)

    func test_PaylikeEngine_initializationTest() throws {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST, loggingMode: .DEBUG)

        XCTAssertNotNil(engine)
        XCTAssertNotNil(engine.client)
        XCTAssertNotNil(engine.webViewModel)
        XCTAssertNotNil(engine.repository)
        XCTAssertNotNil(engine.webViewModel)
        
        XCTAssertNil(engine.error)

        XCTAssertEqual(engine.merchantID, merchantId)
        XCTAssertEqual(engine.engineMode, .TEST)
        XCTAssertEqual(engine.loggingMode, .DEBUG)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
    }
    
    func test_PaylikeEngine_initializationLive() throws {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .LIVE, loggingMode: .RELEASE)
        
        XCTAssertNotNil(engine)
        XCTAssertNotNil(engine.client)
        XCTAssertNotNil(engine.webViewModel)
        XCTAssertNotNil(engine.repository)
        XCTAssertNotNil(engine.webViewModel)
        
        XCTAssertNil(engine.error)
        
        XCTAssertEqual(engine.merchantID, merchantId)
        XCTAssertEqual(engine.engineMode, .LIVE)
        XCTAssertEqual(engine.loggingMode, .RELEASE)
        XCTAssertEqual(engine.state, .WAITING_FOR_INPUT)
    }
    
    func test_PaylikeEngine_setLoggingMode() throws {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST, loggingMode: .DEBUG)
        
        engine.setLoggignMode(newMode: .RELEASE)
        XCTAssertEqual(engine.loggingMode, .RELEASE)
        
        engine.setLoggignMode(newMode: .DEBUG)
        XCTAssertEqual(engine.loggingMode, .DEBUG)
    }
    
    func test_PaylikeEngine_setLoggingFn() throws {
        let engine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST, loggingMode: .DEBUG)
        class EncodableTestClass: Encodable {
            public var testField: Int = 0
        }
        let encodableTestClass = EncodableTestClass()
        let fn: (Encodable) -> Void = { obj in
            if let testObj = obj as? EncodableTestClass {
                testObj.testField = 1
            }
        }
        engine.loggingFn = fn
        engine.loggingFn(encodableTestClass)
        XCTAssertEqual(encodableTestClass.testField, 1)
    }
}
