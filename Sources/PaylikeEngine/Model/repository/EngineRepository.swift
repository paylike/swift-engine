import PaylikeClient

/**
 * Stores information about the current payment flow
 */
public struct EngineReposity {
    public var paymentRepository: CreatePaymentRequest?
    public var htmlRepository: String?
    public var transactionId: String?
    public var authorizationId: String?
    
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
