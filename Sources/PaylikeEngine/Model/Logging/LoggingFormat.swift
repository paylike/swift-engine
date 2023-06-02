import PaylikeClient

/**
 * Describes information for a log line
 */
struct Loggingformat : Encodable {
    var t: String
    var state: EngineState
    var paymentData: CreatePaymentRequest?
}
