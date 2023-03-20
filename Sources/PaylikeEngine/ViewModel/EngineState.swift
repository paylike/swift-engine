import Foundation

/**
 * Defines the possible states of the `PaylikeEngine`
 */
public enum EngineState {
    case WAITING_FOR_INPUT
    case WEBVIEW_CHALLENGE_STARTED
    case WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED
    case SUCCESS
    case ERROR
    
    /**
     * Gets the expected number of hints to have at the actual state
     */
    static func getNumberOfExpectedHints(state: Self) -> Int {
        return { switch state {
            case .WAITING_FOR_INPUT:
                return 0
            case .WEBVIEW_CHALLENGE_STARTED:
                return 6
            case .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED:
                return 8
            case .SUCCESS:
                return 10
            case .ERROR:
                return 0
        }}()
    }
}
