import PaylikeClient
import PaylikeRequest

extension PaylikeEngine {
    
    /**
     * Resetting engine field to default
     */
    public func resetEngine() {
        loggingFn(LoggingFormat(t: "Resetting engine", state: self.internalState))
        
        saveState(newState: .WAITING_FOR_INPUT)
        saveErrorObject(newErrorObject: nil)
        savePaymentRepository(newRepository: nil)
        saveHtmlRepository(newHtml: nil)
        saveTransactionIdRepository(newTransactionId: nil)
        saveAuthorizationIdRepository(newAuthorizationId: nil)
        
        webViewModel?.dropWebView()
        
        loggingFn(LoggingFormat(t: "Resetted engine", state: self.internalState))
    }
        
    /**
     * Sets the engine to error state and loads an `e` error object to it
     */
    public func prepareError(_ error: Error) {
        
        loggingFn(LoggingFormat(t: "Setting error object with: \(error)", state: self.internalState))
        
        let errorObject = EngineErrorObject(
            message: error.localizedDescription,
            httpClientError: error as? HTTPClientError,
            clientError: error as? ClientError,
            webViewError: error as? WebViewError,
            engineError: error as? EngineError
        )
        saveErrorObject(newErrorObject: errorObject)
        saveState(newState: .ERROR)
        
        loggingFn(LoggingFormat(t: "Error state set with: \(error)", state: self.internalState))
    }
    
    func saveErrorObject(newErrorObject: EngineErrorObject?) {
        internalError = newErrorObject
        objectWillChange.send()
    }
    func saveState(newState: EngineState) {
        internalState = newState
        objectWillChange.send()
    }
    func savePaymentRepository(newRepository: CreatePaymentRequest?) {
        repository.paymentRepository = newRepository
        objectWillChange.send()
    }
    func saveHtmlRepository(newHtml: String?) {
        repository.htmlRepository = newHtml
        objectWillChange.send()
    }
    func saveTransactionIdRepository(newTransactionId: String?) {
        repository.transactionId = newTransactionId
        objectWillChange.send()
    }
    func saveAuthorizationIdRepository(newAuthorizationId: String?) {
        repository.authorizationId = newAuthorizationId
        objectWillChange.send()
    }
}
