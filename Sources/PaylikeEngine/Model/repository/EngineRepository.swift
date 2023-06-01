import PaylikeClient

/**
 * Stores information about the current payment flow
 */
public struct EngineReposity {
    public var paymentRepository: CreatePaymentRequest? =  nil
    public var htmlRepository: String? = nil
    public var transactionId: String? = nil
    public var authorizationId: String? = nil
    
    public init(
        paymentRepository: CreatePaymentRequest? = nil,
        htmlRepository: String? = nil,
        transactionId: String? = nil,
        authorizationId: String? = nil
    ) {
        self.paymentRepository = paymentRepository
        self.htmlRepository = htmlRepository
        self.transactionId = transactionId
        self.authorizationId = authorizationId
    }
}
