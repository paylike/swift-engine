import Combine
import SwiftUI
import WebKit

/**
 * Public protocol to provide ViewModel for the WebVIew in case of ThreeDS payment flow
 */
public protocol WebViewModel: ObservableObject {
    
    var engine: (any Engine)? { get }
    var webView: WKWebView? { get }

    var paylikeWebView: PaylikeWebView? { get }
    var shouldRenderWebView: Bool { get }
    
    func createWebView()
    func dropWebView()
}

/**
 * Public final implementation of ThreeDS supporting WebView, default in PaylikeEngine
 */
public final class PaylikeWebViewModel: WebViewModel {
    
    
    
    weak var _engine: PaylikeEngine?
    public var engine: (any Engine)? {
        return _engine
    }
    
    
    var _webView: WKWebView?
    public var webView: WKWebView? {
        return _webView
    }
    
    private var _paylikeWebView: PaylikeWebView?
    public var paylikeWebView: PaylikeWebView? {
        return _paylikeWebView
    }
    @Published private var _shouldRenderWebView = false
    public var shouldRenderWebView: Bool {
        return _shouldRenderWebView
    }
    private var hintsListener: HintsListener?
    private var cancellables: Set<AnyCancellable> = []

    public init(engine: PaylikeEngine) {
        self._engine = engine
    }
    
    /**
     * Initialization of webView with hintsListener
     */
    public func createWebView() {
        hintsListener = HintsListener(webViewViewModel: self)
        _webView = initWebView(hintsListener: hintsListener!)
        setUpEngineListening()
        _paylikeWebView = PaylikeWebView(webView: webView!)
        
        if let engine = _engine {
            engine.loggingFn(Loggingformat(t: "WebView created", state: engine.state))
        }
    }
    
    /**
     * Reset webView
     */
    public func dropWebView() {
        _webView = nil
        _paylikeWebView = nil
        hintsListener = nil
        cancellables = []
        _shouldRenderWebView = false
        
        if let engine = _engine {
            engine.loggingFn(Loggingformat(t: "WebView created", state: engine.state))
        }
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
        self._engine!.$_state
            .sink(receiveValue: { state in
                switch state {
                    case .WAITING_FOR_INPUT:
                        self._shouldRenderWebView = false
                    case .WEBVIEW_CHALLENGE_STARTED:
                        self._shouldRenderWebView = true
                    case .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED:
                        self.webView!.evaluateJavaScript(setIFrameContent(to: (self.engine?.repository.htmlRepository!)!))
                    case .SUCCESS:
                        self._shouldRenderWebView = false
                    case .ERROR:
                        self._shouldRenderWebView = false
                }
            })
            .store(in: &cancellables)
    }
}
