import PaylikeClient
import PaylikeRequest

extension PaylikeEngine {
    
    /**
     * Resetting engine field to default
     */
    public func resetEngine() {
        loggingFn(Loggingformat(t: "Resetting engine", state: self.state))
        
        state = EngineState.WAITING_FOR_INPUT
        error = nil
        repository = EngineReposity()
        webViewModel?.dropWebView()
        
        loggingFn(Loggingformat(t: "Resetted engine", state: self.state))

        objectWillChange.send()
    }
    
    /**
     * Resetting engine field to default on MainActor
     */
    public func resetEngine() async {
        await MainActor.run {
            resetEngine()
        }
    }
    
    func saveState(newState: EngineState) {
        state = newState
        objectWillChange.send()
    }
    func saveState(newState: EngineState) async {
        await MainActor.run {
            saveState(newState: newState)
        }
    }
    
    public func prepareError(e: Error) {
        saveState(newState: .ERROR)
        
        loggingFn(Loggingformat(t: "Setting error object with: \(e)", state: self.state))
        
        error = EngineErrorObject(
            message: e.localizedDescription,
            httpClientError: e as? HTTPClientError,
            clientError: e as? ClientError,
            webViewError: e as? WebViewError,
            engineError: e as? EngineError
        )
        saveErrorObject(newErrorObject: error)
    }
    func saveErrorObject(newErrorObject: EngineErrorObject?) {
        error = newErrorObject
        objectWillChange.send()
    }
    func saveErrorObject(newErrorObject: EngineErrorObject?) async {
        await MainActor.run {
            saveErrorObject(newErrorObject: newErrorObject)
        }
    }
    
    func savePaymentRepository(newRepository: CreatePaymentRequest) {
        repository.paymentRepository = newRepository
        objectWillChange.send()
    }
    func savePaymentRepository(newRepository: CreatePaymentRequest) async {
        await MainActor.run {
            savePaymentRepository(newRepository: newRepository)
        }
    }
    
    func saveHtmlRepository(newHtml: String?) {
        repository.htmlRepository = newHtml
        objectWillChange.send()
    }
    func saveHtmlRepository(newHtml: String?) async {
        await MainActor.run {
            saveHtmlRepository(newHtml: newHtml)
        }
    }
    
    func saveTransactionIdRepository(newTransactionId: String?) {
        repository.transactionId = newTransactionId
        objectWillChange.send()
    }
    func saveTransactionIdRepository(newTransactionId: String?) async {
        await MainActor.run {
            saveTransactionIdRepository(newTransactionId: newTransactionId)
        }
    }
    
    func saveAuthorizationIdRepository(newAuthorizationId: String?) {
        repository.authorizationId = newAuthorizationId
        objectWillChange.send()
    }
     func saveAuthorizationIdRepository(newAuthorizationId: String?) async {
        await MainActor.run {
            saveAuthorizationIdRepository(newAuthorizationId: newAuthorizationId)
        }
    }
}
