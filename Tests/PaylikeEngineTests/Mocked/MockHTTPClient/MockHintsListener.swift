import Foundation
import PaylikeEngine

class MockHintsListener: Listener {
    
    private weak var engine: PaylikeEngine?
    
    private var _handler: ((_ isReady: Bool, _ hints: [String]) -> Void) = { _, _ in }
    var handler: ((_ isReady: Bool, _ hints: [String]) -> Void) {
        return _handler
    }

    required init(webViewViewModel: any WebViewModel) {
        self.engine = (webViewViewModel.engine as! PaylikeEngine)

        self._handler = { _, hints in
            if !hints.isEmpty {
                self.saveNewHintsToEngine(hints: hints)
                self.triggerEnginePaymentFunction()
            }
            else {
                self.engine!.prepareError(e: WebViewError.HintsListenerError)
            }
        }
    }
    
    private func saveNewHintsToEngine(hints: [String]) {
        hints.forEach { hint in
            if !engine!.repository.paymentRepository!.hints.contains(hint) {
                engine!.repository.paymentRepository!.hints.append(hint)
            }
        }
    }
    
    private func triggerEnginePaymentFunction() {
        switch engine!.state {
            case .WEBVIEW_CHALLENGE_STARTED:
                Task {
                    await engine!.continuePayment()
                }
            case .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED:
                Task {
                    await engine!.finishPayment()
                }
            default:
                break
        }
    }
    
    func hintsListenerTrigger(hints: [String]) {
        handler(false, hints)
    }
}
