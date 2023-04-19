import Combine
import SwiftUI
import WebKit

/**
 *
 */
public class PaylikeWebViewModel: ObservableObject {
    
    internal weak var engine: PaylikeEngine?
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private (set) public var shouldRenderWebView = false
    
    internal var webView: WKWebView?
    private (set) public var paylikeWebView: PaylikeWebView?
    private var hintsListener: HintsListener?
    
    init(engine: PaylikeEngine) {
        self.engine = engine
    }
    
    func createWebView() {
        hintsListener = HintsListener(vm: self)
        webView = initWebView(hintsListener: hintsListener!)
        setUpEngineListening()
        paylikeWebView = PaylikeWebView(webView: webView!)
    }
    
    func dropWebView() {
        webView = nil
        paylikeWebView = nil
        hintsListener = nil
    }
    
    private func initWebView(hintsListener: HintsListener) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(hintsListener, name: "HintsListener")
        config.userContentController = contentController
        let webView = WKWebView(
            frame: .init(origin: .zero, size: CGSize(width: 300, height: 300)),
            configuration: config
        )
        webView.load(Data(webViewIFrame.utf8), mimeType: "text/html", characterEncodingName: "utf-8", baseURL: URL(string: "https:///b.paylike.io")!)
        return webView
    }
    
    private func setUpEngineListening() {
        self.engine!.$state
            .sink(receiveValue: { state in
                switch state {
                    case .WAITING_FOR_INPUT:
                        self.shouldRenderWebView = false
                    case .WEBVIEW_CHALLENGE_STARTED:
                        self.shouldRenderWebView = true
                    case .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED:
                        self.webView!.evaluateJavaScript(setIFrameContent(to: self.engine?.repository.htmlRepository ?? "")) { stuff, error in
                            if let error = error {
                                debugPrint("In webView state sink (WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED) evaluated JS error occured: \(error)")
                            }
                        }
                    case .SUCCESS:
                        self.shouldRenderWebView = false
                    case .ERROR:
                        self.shouldRenderWebView = false
                }
            })
            .store(in: &cancellables)
    }
}
