import AnyCodable
import Combine
import Foundation
import PaylikeClient
import PaylikeRequest

/**
 * Paylike engine protocol defining the minimal required fields and public API
 */
public protocol Engine: ObservableObject {
    
    var client: Client { get set }
    var webViewModel: (any WebViewModel)? { get set }
    
    var state: Published<EngineState> { get }
    var error: EngineErrorObject? { get }
    var repository: EngineReposity { get set }

    func addEssentialPaymentData(applePayToken: String) async
    func addEssentialPaymentData(cardNumber: String, cvc: String, month: Int, year: Int) async
    func addDescriptionPaymentData(paymentAmount: PaymentAmount?, paymentPlanDataList: [PaymentPlan]?, paymentUnplannedData: PaymentUnplanned?, paymentTestData: PaymentTest?)
    func addAdditionalPaymentData(textData: String?, customData: AnyEncodable?)
    
    func resetEngine()
    func prepareError(_ error: Error)
    
    func startPayment() async
    func continuePayment() async
    func finishPayment() async
}


/**
 * Paylike engine wrapper class to support Paylike transactions towards the API
 */
public final class PaylikeEngine: Engine {
    
    public var merchantID: String
    
    private var _client: Client = PaylikeClient()
    public var client: any Client {
        get {
            return _client
        }
        set {
            _client = newValue
        }
    }
    
    private var _webViewModel: (any WebViewModel)?
    public var webViewModel: (any WebViewModel)? {
        get {
            return _webViewModel
        }
        set {
            _webViewModel = newValue
        }
    }
    
    public var engineMode: EngineMode
    
    public var loggingMode: LoggingMode
    
    public var loggingFn: ((Encodable) -> Void) = { obj in
        print("Engine logger:", terminator: " ")
        debugPrint(obj)
    }
    
    @Published var internalState = EngineState.WAITING_FOR_INPUT
    public /*internal (set)*/ var state: Published<EngineState> {
        get {
            return _internalState
        }
        set {
            _internalState = newValue
            self.objectWillChange.send()
        }
    }
    @Published var _error: EngineErrorObject?
    public /*internal (set)*/ var error: EngineErrorObject? {
        get {
            return _error
        }
        set {
            _error = newValue
            self.objectWillChange.send()
        }
    }
    @Published var _repository = EngineReposity()
    public var repository: EngineReposity {
        get {
            return _repository
        }
        set {
            _repository = newValue
            self.objectWillChange.send()
        }
    }

    /**
     * Initialize engine with the default parameters
     */
    public init(
        merchantID: String,
        engineMode: EngineMode = .TEST,
        loggingMode: LoggingMode = .DEBUG
    ) {
        self.merchantID = merchantID
        self.engineMode = engineMode
        self.loggingMode = loggingMode
        setLoggignMode(newMode: loggingMode)
        webViewModel = PaylikeWebViewModel(engine: self)
    }
    
    
    /**
     * Sets logging mode the the given mode. Sets the logger function according to the new mode.
     *
     * Debug mode logs messages to the console
     * Release mode does not log to the console
     */
    public func setLoggignMode(newMode: LoggingMode) {
        loggingMode = newMode
        setLoggerFns(basedOn: newMode)
    }
    private func setLoggerFns(basedOn engineMode: LoggingMode) {
        switch engineMode {
            case .DEBUG:
                loggingFn = { obj in
                    print("Engine logger:", terminator: " ")
                    debugPrint(obj)
                }
                client.loggingFn = { obj in
                    print("Client logger:", terminator: " ")
                    debugPrint(obj)
                }
                client.httpClient.loggingFn = { obj in
                    print("HTTP Client logger:", terminator: " ")
                    debugPrint(obj)
                }
            case .RELEASE:
                loggingFn = { _ in }
                client.loggingFn = { _ in }
                client.httpClient.loggingFn = { _ in }
        }
    }
}
