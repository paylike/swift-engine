import Foundation

/**
 * Describes errors regarding the WebView and it's close components
 */
public enum WebViewError: Error, LocalizedError {
    case NotImplemented
    case HintsListenerError
    
    /**
     * Localized text of the error messages
     */
    // @TODO: Change text literals to `NSLocalizedString`s
    // @TODO: Generate localized string file in Xcode
    public var errorDescription: String? {
        switch self {
                
            case .NotImplemented:
                return "NotImplemented"
            case .HintsListenerError:
                return "Error occured in WebView's HintsListener"
        }
    }
}
