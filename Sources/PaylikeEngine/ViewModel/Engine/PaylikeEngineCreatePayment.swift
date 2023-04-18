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
            
            loggingFn(Loggingformat(t: "Starting payment"))
            
            let response = try await payment()
            if let htmlBody = response.HTMLBody {
                await saveHtmlRepository(newHtml: htmlBody)
                await saveState(newState: .WEBVIEW_CHALLENGE_STARTED)
            } else if let transactionId = response.createPaymentResponse.transactionId {
                await saveTransactionIdRepository(newTransactionId: transactionId)
                await saveState(newState: .SUCCESS)
            } else if let authorizationId = response.createPaymentResponse.authorizationId {
                await saveAuthorizationIdRepository(newAuthorizationId: authorizationId)
                await saveState(newState: .SUCCESS)
            } else {
                throw EngineError.PaymentFlowError(caller: #function, cause: "No htmlBody nor transactionId")
            }
        } catch {
            prepareError(e: error)
        }
    }
    
    /**
     *
     */
    public func continuePayment() async {
        do {
            try checkValidState(valid: .WEBVIEW_CHALLENGE_STARTED, callerFunc: #function)
            
            loggingFn(Loggingformat(t: "Continuing payment"))
            
            let response = try await payment()
            if let htmlBody = response.HTMLBody {
                await saveHtmlRepository(newHtml: htmlBody)
                await saveState(newState: .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED)
            } else if let transactionId = response.createPaymentResponse.transactionId {
                await saveTransactionIdRepository(newTransactionId: transactionId)
                await saveState(newState: .SUCCESS)
            } else if let authorizationId = response.createPaymentResponse.authorizationId {
                await saveAuthorizationIdRepository(newAuthorizationId: authorizationId)
                await saveState(newState: .SUCCESS)
            } else {
                throw EngineError.PaymentFlowError(caller: #function, cause: "No htmlBody nor transactionId")
            }
        } catch {
            prepareError(e: error)
        }
    }
    
    /**
     *
     */
    public func finishPayment() async {
        do {
            try checkValidState(valid: .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED, callerFunc: #function)
            
            loggingFn(Loggingformat(t: "Finishing payment"))
            
            let response = try await payment()
            if response.HTMLBody != nil {
                throw EngineError.PaymentFlowError(caller: #function, cause: "Response should not be HTML")
            } else if let transactionId = response.createPaymentResponse.transactionId {
                await saveTransactionIdRepository(newTransactionId: transactionId)
            } else if let authorizationId = response.createPaymentResponse.authorizationId {
                await saveAuthorizationIdRepository(newAuthorizationId: authorizationId)
            } else {
                throw EngineError.PaymentFlowError(caller: #function, cause: "No transactionId nor authorizationId")
            }
            await saveState(newState: .SUCCESS)
        } catch {
            prepareError(e: error)
        }
    }
    /**
     *
     */
    fileprivate func payment() async throws -> PaylikeClientResponse {
        try isNumberOfHintsRight()
        guard engineMode == .TEST
                && repository.paymentRepository!.test != nil else {
            throw EngineError.UnimplementedError // @TODO: change error type
        }
        guard var paymentRepository = repository.paymentRepository else {
            throw EngineError.PaymentRespositoryIsNotInitialised
        }
        
        let response =  try await paylikeClient.createPayment(with: paymentRepository)
        
        if let newHints = response.createPaymentResponse.hints {
            paymentRepository.hints = newHints
            await savePaymentRepository(newRepository: paymentRepository)
        }
        return response
    }
}
