import Foundation
import PaylikeRequest
import PaylikeClient

/**
 * Encapsulates the error message and the causing error object
 */
public struct EngineErrorObject {
    public let message: String
    public let httpClientError: HTTPClientError?
    public let clientError: ClientError?
    public let webViewError: WebViewError?
    public let engineError: EngineError?
}
