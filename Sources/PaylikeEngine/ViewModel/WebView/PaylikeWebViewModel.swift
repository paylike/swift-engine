import Combine
import SwiftUI
import WebKit

/**
 * Public protocol to provide ViewModel for the WebVIew in case of ThreeDS payment flow
 */
public protocol WebViewModel: ObservableObject {
    var paylikeWebView: PaylikeWebView? { get }
    var shouldRenderWebView: Bool { get }
    
    func createWebView()
    func dropWebView()
}

/**
 * Public final implementation of ThreeDS supporting WebView, default in PaylikeEngine
 */
public final class PaylikeWebViewModel: WebViewModel {
    
    weak var engine: PaylikeEngine?
    var webView: WKWebView?
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
        self.engine = engine
    }
    
    /**
     * Initialization of webView with hintsListener
     */
    public func createWebView() {
        hintsListener = HintsListener(vm: self)
        webView = initWebView(hintsListener: hintsListener!)
        setUpEngineListening()
        _paylikeWebView = PaylikeWebView(webView: webView!)
    }
    
    /**
     * Reset webView
     */
    public func dropWebView() {
        webView = nil
        _paylikeWebView = nil
        hintsListener = nil
        cancellables = []
        _shouldRenderWebView = false
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
