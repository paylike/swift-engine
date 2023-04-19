import PaylikeClient
import PaylikeRequest

/**
 *
 */
extension PaylikeEngine {
    
    public func resetEngine() {
        loggingFn(Loggingformat(t: "Resetting engine"))
        
        state = EngineState.WAITING_FOR_INPUT
        error = nil
        repository = EngineReposity()
        webViewModel?.dropWebView()
        
        objectWillChange.send()
    }
    
    public func resetEngine() async {
        await MainActor.run {
            resetEngine()
        }
    }
    
    internal func saveState(newState: EngineState) {
        state = newState
        objectWillChange.send()
    }
    internal func saveState(newState: EngineState) async {
        await MainActor.run {
            saveState(newState: newState)
        }
    }
    
    internal func prepareError(e: Error) {
        saveState(newState: .ERROR)
        
        loggingFn(Loggingformat(t: "Setting error object with: \(e)"))
        
        error = EngineErrorObject(
            message: e.localizedDescription,
            httpClientError: e as? HTTPClientError,
            clientError: e as? ClientError,
            webViewError: e as? WebViewError,
            engineError: e as? EngineError
        )
        saveErrorObject(newErrorObject: error)
    }
    internal func saveErrorObject(newErrorObject: EngineErrorObject?) {
        error = newErrorObject
        objectWillChange.send()
    }
    internal func saveErrorObject(newErrorObject: EngineErrorObject?) async {
        await MainActor.run {
            saveErrorObject(newErrorObject: newErrorObject)
        }
    }
    
    internal func savePaymentRepository(newRepository: CreatePaymentRequest) {
        repository.paymentRepository = newRepository
        objectWillChange.send()
    }
    internal func savePaymentRepository(newRepository: CreatePaymentRequest) async {
        await MainActor.run {
            savePaymentRepository(newRepository: newRepository)
        }
    }
    
    internal func saveHtmlRepository(newHtml: String?) {
        repository.htmlRepository = newHtml
        objectWillChange.send()
    }
    internal func saveHtmlRepository(newHtml: String?) async {
        await MainActor.run {
            saveHtmlRepository(newHtml: newHtml)
        }
    }
    
    internal func saveTransactionIdRepository(newTransactionId: String?) {
        repository.transactionId = newTransactionId
        objectWillChange.send()
    }
    internal func saveTransactionIdRepository(newTransactionId: String?) async {
        await MainActor.run {
            saveTransactionIdRepository(newTransactionId: newTransactionId)
        }
    }
    
    internal func saveAuthorizationIdRepository(newAuthorizationId: String?) {
        repository.authorizationId = newAuthorizationId
        objectWillChange.send()
    }
    internal func saveAuthorizationIdRepository(newAuthorizationId: String?) async {
        await MainActor.run {
            saveAuthorizationIdRepository(newAuthorizationId: newAuthorizationId)
        }
    }
}
