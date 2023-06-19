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
    var shouldRenderWebView: Published<Bool> { get set }
    
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
    @Published private var privateShouldRenderWebView = false
    public var shouldRenderWebView: Published<Bool> {
        get {
            return _privateShouldRenderWebView
        }
        set {
            _privateShouldRenderWebView = newValue
        }
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
            engine.loggingFn(LoggingFormat(t: "WebView created", state: engine.internalState))
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
        privateShouldRenderWebView = false
                
        if let engine = _engine {
            engine.loggingFn(LoggingFormat(t: "WebView dropped", state: engine.internalState))
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
        self._engine!.$internalState
            .sink(receiveValue: { state in
                switch state {
                    case .WAITING_FOR_INPUT:
                        self.privateShouldRenderWebView = false
                    case .WEBVIEW_CHALLENGE_STARTED:
                        self.privateShouldRenderWebView = true
                    case .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED:
                        Task {
                            await MainActor.run {
                                self.webView!.evaluateJavaScript(setIFrameContent(to: (self.engine?.repository.htmlRepository!)!))
                            }
                        }
                    case .SUCCESS:
                        self.privateShouldRenderWebView = false
                    case .ERROR:
                        self.privateShouldRenderWebView = false
                }
            })
            .store(in: &cancellables)
    }
}
