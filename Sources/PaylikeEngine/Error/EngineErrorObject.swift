import PaylikeRequest
import PaylikeClient

/**
 *
 */
public struct EngineErrorObject {
    let message: String
    let httpClientError: HTTPClientError?
    let clientError: ClientError?
    let webViewError: WebViewError?
    let engineError: EngineError?
}
