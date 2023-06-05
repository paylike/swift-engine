import WebKit

/**
 * Public protocol to provide Listener interface for the WebView JS content
 */
public protocol Listener {
    init(webViewViewModel: any WebViewModel)
    var handler: ((_ isReady: Bool, _ hints: [String]) -> Void) { get }
}

/**
 * Listens to hints emitted by the WebView
 */
final class HintsListener: NSObject, WKScriptMessageHandler, Listener {
    private weak var engine: PaylikeEngine?
    private (set) internal var handler: ((_ isReady: Bool, _ hints: [String]) -> Void) = { _, _ in }
    
    public init(webViewViewModel: any WebViewModel) {
        super.init()
        self.engine = (webViewViewModel.engine as! PaylikeEngine)
        
        self.handler = { isReady, hints in
            if isReady == true {
                webViewViewModel.webView!.evaluateJavaScript(setIFrameContent(to: (webViewViewModel.engine?.repository.htmlRepository!)!))
            } else if !hints.isEmpty {
                self.saveNewHintsToEngine(hints: hints)
                self.triggerProceedPayment()
            }
            else {
                self.engine!.prepareError(e: WebViewError.HintsListenerError)
            }
        }
    }
        
    private func saveNewHintsToEngine(hints: [String]) {
        hints.forEach { hint in
            if !engine!._repository.paymentRepository!.hints.contains(hint) {
                engine!._repository.paymentRepository!.hints.append(hint)
            }
        }
    }
    
    private func triggerProceedPayment() {
        engine!.proceedPayment()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let isReady = message.body as? String,
           isReady == "isReady" {
            handler(true, [])
        } else if
            let hints = try? JSONDecoder().decode(Hints.self, from: Data((message.body as! String).utf8)) {
            handler(false, hints.hints)
        }
        else {
            handler(false, [])
        }
    }
}
