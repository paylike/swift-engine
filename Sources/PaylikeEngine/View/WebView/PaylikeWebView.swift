import Foundation
import SwiftUI
import WebKit

#if os(macOS)
public typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias ViewRepresentable = UIViewRepresentable
#endif

/**
 * A wrapper for a UIKit view that you use to integrate that view into your SwiftUI view hierarchy.
 */
public struct PaylikeWebView: ViewRepresentable {
    
    var webView: WKWebView

    public typealias UIViewType = WKWebView
    public func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    public func updateUIView(_ uiView: WKWebView, context: Context) { }
    
    public typealias NSViewType = WKWebView
    public func makeNSView(context: Context) -> WKWebView {
        return webView
    }
    public func updateNSView(_ nsView: WKWebView, context: Context) { }
}
