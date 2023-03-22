import PaylikeClient
import PaylikeLuhn
import PaylikeRequest
import Foundation

/**
 * Paylike engine wrapper class to support Paylike transactions towards the API
 */
public class PaylikeEngine: ObservableObject {
    
    internal(set) public var merchantID: String
    
    internal(set) public var engineMode: EngineMode
    
    @Published internal(set) public var state: EngineState = EngineState.WAITING_FOR_INPUT
    
    @Published internal(set) public var error: EngineErrorObject?
    
    internal(set) public var repository: EngineReposity = EngineReposity()
    
    public var paylikeClient = PaylikeClient()
    
    public var loggingFn: ((Encodable) -> Void) = { obj in
        print("Engine logger:", terminator: " ")
        debugPrint(obj)
    }
    
    public init(
        merchantID: String,
        engineMode: EngineMode
    ) {
        self.merchantID = merchantID
        self.engineMode = engineMode
        
        switch engineMode {
            case .LIVE:
                loggingFn = { _ in }
                paylikeClient.loggingFn = { _ in }
                paylikeClient.httpClient.loggingFn = { _ in }
            case .TEST:
                break
        }
    }
    
    public func resetEngineState() {
        
        loggingFn(Loggingformat(t: "Resetting engine"))
        
        self.state = EngineState.WAITING_FOR_INPUT
        self.error = nil
        self.repository = EngineReposity()
    }
    
    internal func areEssentialPaymentRepositoryFieldsAdded() throws {
        try isPaymentRepositoryInitialised()
        
        let hasCard = repository.paymentRepository!.card != nil
        let hasApplePay = repository.paymentRepository!.applepay != nil
        guard hasCard != hasApplePay
        else {
            throw EngineError.EssentialPaymentRepositoryDataFailure(hasBoth: hasCard && hasApplePay)
        }
    }
    
    internal func isPaymentRepositoryInitialised() throws {
        guard repository.paymentRepository != nil else {
            throw EngineError.PaymentRespositoryIsNotInitialised
        }
    }
    
    internal func initialisePaymentRepositoryIfNil() {
        if repository.paymentRepository == nil {
            repository.paymentRepository = CreatePaymentRequest(merchantID: PaymentIntegration(merchantId: self.merchantID))
        }
    }
    
    internal func checkValidState(valid state: EngineState, callerFunc: String) throws {
        guard self.state == state else {
            throw EngineError.InvalidEngineState(caller: callerFunc, actual: self.state, expected: state)
        }
    }
    
    internal func isNumberOfHintsRight() throws {
        try isPaymentRepositoryInitialised()
        let actual = repository.paymentRepository!.hints.count
        let expected = EngineState.getNumberOfExpectedHints(state: self.state)
        guard actual == expected else {
            throw EngineError.WrongAmountOfHints(actual: actual, expected: expected)
        }
    }
    
    internal func addHintsToRepository(hints: [String]?) throws {
        try isPaymentRepositoryInitialised()
        if let hints = hints {
            repository.paymentRepository!.hints = hints
        }
    }
    
    internal func setErrorState(e: Error) {
        
        loggingFn(Loggingformat(t: "Error: \(e)"))
        
        error = EngineErrorObject(
            message: e.localizedDescription,
            httpClientError: e as? HTTPClientError,
            clientError: e as? ClientError,
            webViewError: e as? WebViewError,
            engineError: e as? EngineError
        )
        state = .ERROR
    }
}
