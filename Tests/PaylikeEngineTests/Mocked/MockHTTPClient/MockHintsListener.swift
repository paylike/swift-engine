import Foundation
@testable import PaylikeEngine

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
                self.triggerProceedPayment()
            }
            else {
                self.engine!.prepareError(WebViewError.HintsListenerError)
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
    
    private func triggerProceedPayment() {
        engine!.proceedPayment()
    }
    
    func hintsListenerTrigger(hints: [String]) {
        handler(false, hints)
    }
}
