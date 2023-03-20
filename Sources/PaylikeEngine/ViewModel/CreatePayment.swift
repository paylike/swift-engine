import PaylikeClient

/**
 *
 */
extension PaylikeEngine {
    
    /**
     *
     */
    public func startPayment() async {
        do {
            try checkValidState(valid: .WAITING_FOR_INPUT, callerFunc: #function)
            try areEssentialPaymentRepositoryFieldsAdded()
            try isNumberOfHintsRight()
            let response = try await payment()
            try addHintsToRepository(hints: response.createPaymentResponse.hints)
            
            if let htmlBody = response.HTMLBody {
                repository.htmlRepository = htmlBody
                state = .WEBVIEW_CHALLENGE_STARTED
            } else if let transactionId = response.createPaymentResponse.transactionId {
                repository.transactionId = transactionId
                state = .SUCCESS
            } else if let authorizationId = response.createPaymentResponse.authorizationId {
                repository.transactionId = authorizationId
                state = .SUCCESS
            } else {
                throw EngineError.PaymentFlowError(caller: #function, cause: "No htmlBody & transactionId")
            }
        } catch {
            setErrorState(e: error)
        }
    }
    
    /**
     *
     */
    public func continuePayment() async {
        do {
            try checkValidState(valid: .WEBVIEW_CHALLENGE_STARTED, callerFunc: #function)
            try isNumberOfHintsRight()
            let response = try await payment()
            try addHintsToRepository(hints: response.createPaymentResponse.hints)
            
            if let htmlBody = response.HTMLBody {
                repository.htmlRepository = htmlBody
                state = .WEBVIEW_CHALLENGE_STARTED
            } else if let transactionId = response.createPaymentResponse.transactionId {
                repository.transactionId = transactionId
                state = .SUCCESS
            } else if let authorizationId = response.createPaymentResponse.authorizationId {
                repository.transactionId = authorizationId
                state = .SUCCESS
            } else {
                throw EngineError.PaymentFlowError(caller: #function, cause: "No htmlBody & transactionId")
            }
        } catch {
            setErrorState(e: error)
        }
    }
    
    /**
     *
     */
    public func finishPayment() async {
        do {
            try checkValidState(valid: .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED, callerFunc: #function)
            try isNumberOfHintsRight()
            let response = try await payment()
            try addHintsToRepository(hints: response.createPaymentResponse.hints)
            
            if response.HTMLBody != nil {
                throw EngineError.PaymentFlowError(caller: #function, cause: "Response should not be HTML")
            } else if let transactionId = response.createPaymentResponse.transactionId {
                repository.transactionId = transactionId
            } else if let authorizationId = response.createPaymentResponse.authorizationId {
                repository.transactionId = authorizationId
            } else {
                throw EngineError.PaymentFlowError(caller: #function, cause: "No transactionId nor authorizationId")
            }
            state = .SUCCESS
        } catch {
            setErrorState(e: error)
        }
    }
    
    /**
     *
     */
    fileprivate func payment() async throws -> PaylikeClientResponse {
        
        // @TODO: check on paymentData, decide on how to call the client
        throw EngineError.UnimplementedError
    }
}
