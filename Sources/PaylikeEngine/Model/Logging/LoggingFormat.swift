import PaylikeClient

/**
 * Describes information for a log line
 */
struct LoggingFormat : Encodable {
    var t: String
    var state: EngineState
    var paymentData: CreatePaymentRequest?
}
