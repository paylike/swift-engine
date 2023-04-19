import WebKit

/**
 *
 */
class HintsListener: NSObject, WKScriptMessageHandler {
    private weak var engine: PaylikeEngine?
    private weak var webView: WKWebView?
    private (set) internal var handler: ((_ isReady: Bool, _ hints: [String]) -> Void) = { _, _ in }
    
    init(vm: PaylikeWebViewModel) {
        super.init()
        self.engine = vm.engine
        self.webView = vm.webView
        
        self.handler = { isReady, hints in
            if isReady == true {
                vm.webView!.evaluateJavaScript(setIFrameContent(to: vm.engine?.repository.htmlRepository ?? "")) { stuff, error in
                    if let error = error {
                        debugPrint("In HintsListener Handler evaluated JS error occured: \(error)")
                    }
                }
                
            } else if !hints.isEmpty {
                self.saveNewHintsToEngine(hints: hints)
                self.triggerEnginePaymentFunction()
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
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let isReady = message.body as? String,
           isReady == "isReady" {
            handler(true, [])
        } else if
            let hints = try? JSONDecoder().decode(Hints.self, from: Data((message.body as! String).utf8)) {
            handler(false, hints.hints)
        }
        else {
            debugPrint("HintsListener error happended. The message body is: \(message.body)")
        }
    }
}
