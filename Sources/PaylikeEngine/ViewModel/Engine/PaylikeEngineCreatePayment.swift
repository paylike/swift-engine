import PaylikeClient

extension PaylikeEngine {
    
    /**
     * Starts payment toward the Paylike backend
     *
     * Have to call at the beginning of any payment flow, when every necessary data is set in the repository.
     * Changes state, webView and repository.
     */
    public func startPayment() async {
        do {
            try checkValidState(valid: .WAITING_FOR_INPUT, callerFunc: #function)
            try areEssentialPaymentRepositoryFieldsAdded()
            
            loggingFn(LoggingFormat(t: "Starting payment", state: self.state))
            
            let response = try await payment()
            if let htmlBody = response.HTMLBody {
                await saveHtmlRepository(newHtml: htmlBody)
                await saveState(newState: .WEBVIEW_CHALLENGE_STARTED)
                await MainActor.run {
                    webViewModel?.createWebView()
                }
            } else if let transactionId = response.createPaymentResponse.transactionId {
                await saveTransactionIdRepository(newTransactionId: transactionId)
                await saveState(newState: .SUCCESS)
            } else if let authorizationId = response.createPaymentResponse.authorizationId {
                await saveAuthorizationIdRepository(newAuthorizationId: authorizationId)
                await saveState(newState: .SUCCESS)
            } else {
                throw EngineError.PaymentFlowError(caller: #function, cause: "No htmlBody nor transactionId")
            }
            
            loggingFn(LoggingFormat(t: "Started payment", state: self.state))
        } catch {
            prepareError(e: error)
        }
    }
    
    /**
     * Continues the payment flow
     *
     * Webview calls it.
     * Changes state, webView and repository.
     */
    public func continuePayment() async {
        do {
            try checkValidState(valid: .WEBVIEW_CHALLENGE_STARTED, callerFunc: #function)
            
            loggingFn(LoggingFormat(t: "Continuing payment", state: self.state))
            
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
            
            loggingFn(LoggingFormat(t: "Continued payment", state: self.state))
        } catch {
            prepareError(e: error)
        }
    }
    
    /**
     * Finishes the payment flow
     *
     * Webview calls it when ThreeDS is successfull.
     * Changes state, webView and repository.
     */
    public func finishPayment() async {
        do {
            try checkValidState(valid: .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED, callerFunc: #function)
            
            loggingFn(LoggingFormat(t: "Finishing payment", state: self.state))
            
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
            
            loggingFn(LoggingFormat(t: "Finished payment", state: self.state))
        } catch {
            prepareError(e: error)
        }
    }
    
    fileprivate func payment() async throws -> PaylikeClientResponse {
        try isNumberOfHintsRight()
        guard engineMode == .TEST
                && repository.paymentRepository!.test != nil else {
            throw EngineError.PaymentTestDataIsNil
        }
        guard var paymentRepository = repository.paymentRepository else {
            throw EngineError.PaymentRespositoryIsNotInitialised
        }
        
        let response =  try await client.createPayment(with: paymentRepository)
        
        if let newHints = response.createPaymentResponse.hints {
            paymentRepository.hints = newHints
            await savePaymentRepository(newRepository: paymentRepository)
        }
        return response
    }
}
