import Foundation
import PaylikeRequest
import PaylikeClient

/**
 *
 */
public struct EngineErrorObject {
    public let message: String
    public let httpClientError: HTTPClientError?
    public let clientError: ClientError?
    public let webViewError: WebViewError?
    public let engineError: EngineError?
}

//extension HTTPClientError : Encodable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Keys.self)
//        switch self {
//            case .UnknownError:
//                try container.encode(0, forKey: .rawValue)
//            case .InvalidURL(_):
//                try container.encode(1, forKey: .rawValue)
//            case .NotHTTPURLResponse(_):
//                try container.encode(2, forKey: .rawValue)
//            case .NoHTTPResponse(_, _):
//                try container.encode(3, forKey: .rawValue)
//            case .ResponseCannotBeSerializedToJSON(_):
//                try container.encode(4, forKey: .rawValue)
//            case .ResponseCannotBeSerializedToString(_):
//                try container.encode(5, forKey: .rawValue)
//        }
//    }
//    private enum Keys : String, CodingKey {
//        case rawValue
//    }
//}
//
//extension ClientError : Encodable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Keys.self)
//        switch self {
//            case .NotImplementedError:
//                try container.encode(0, forKey: .rawValue)
//            case .UnknownError:
//                try container.encode(1, forKey: .rawValue)
//            case .PaylikeServerError(_, _, _, _):
//                try container.encode(2, forKey: .rawValue)
//            case .Timeout:
//                try container.encode(3, forKey: .rawValue)
//            case .URLParsingFailed:
//                try container.encode(4, forKey: .rawValue)
//            case .JSONParsingFailed:
//                try container.encode(5, forKey: .rawValue)
//            case .InvalidTokenizeData(_):
//                try container.encode(6, forKey: .rawValue)
//            case .UnsafeNumber(_):
//                try container.encode(7, forKey: .rawValue)
//            case .InvalidExpiry(_, _):
//                try container.encode(8, forKey: .rawValue)
//            case .UnexpectedResponseBody(_):
//                try container.encode(9, forKey: .rawValue)
//            case .NoResponseBody:
//                try container.encode(10, forKey: .rawValue)
//            case .InvalidURLResponse:
//                try container.encode(11, forKey: .rawValue)
//            case .UnexpectedPaymentFlowError(_, _):
//                try container.encode(12, forKey: .rawValue)
//        }
//    }
//    private enum Keys : String, CodingKey {
//        case rawValue
//    }
//}
