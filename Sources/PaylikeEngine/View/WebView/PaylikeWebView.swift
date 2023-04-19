import SwiftUI
import WebKit

/**
 *
 */
public struct PaylikeWebView: UIViewRepresentable {
    public typealias UIViewType = WKWebView
    
    var webView: WKWebView
    
    public func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    public func updateUIView(_ uiView: WKWebView, context: Context) { }
}
