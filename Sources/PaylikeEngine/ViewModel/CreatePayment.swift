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
            
            loggingFn(Loggingformat(t: "Starting payment"))
            
            try checkValidState(valid: .WAITING_FOR_INPUT, callerFunc: #function)
            try areEssentialPaymentRepositoryFieldsAdded()
            let response = try await payment()
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
                throw EngineError.PaymentFlowError(caller: #function, cause: "No htmlBody nor transactionId")
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
            
            loggingFn(Loggingformat(t: "Continuing payment"))
            
            try checkValidState(valid: .WEBVIEW_CHALLENGE_STARTED, callerFunc: #function)
            let response = try await payment()
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
                throw EngineError.PaymentFlowError(caller: #function, cause: "No htmlBody nor transactionId")
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
            
            loggingFn(Loggingformat(t: "Finishing payment"))

            try checkValidState(valid: .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED, callerFunc: #function)
            let response = try await payment()
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
        try isNumberOfHintsRight()
        // @TODO: do we need this check? if the server receives a bad request data object (so without test field) then i throws failure
        guard self.engineMode == .TEST
                && repository.paymentRepository!.test != nil
        else {
            throw EngineError.UnimplementedError // @TODO: change error type
        }
        let response =  try await paylikeClient.createPayment(with: repository.paymentRepository!)
        try addHintsToRepository(hints: response.createPaymentResponse.hints)
        return response
    }
}
