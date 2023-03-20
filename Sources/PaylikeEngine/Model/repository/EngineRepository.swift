import PaylikeClient

/**
 *
 */
public struct EngineReposity {
    public var paymentRepository: CreatePaymentRequest? =  nil
    public var htmlRepository: String? = nil
    public var transactionId: String? = nil
    
    public init(
        paymentRepository: CreatePaymentRequest? = nil,
        htmlRepository: String? = nil,
        transactionId: String? = nil
    ) {
        self.paymentRepository = paymentRepository
        self.htmlRepository = htmlRepository
        self.transactionId = transactionId
    }
}
