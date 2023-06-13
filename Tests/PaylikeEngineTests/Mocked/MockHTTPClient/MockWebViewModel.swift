import Combine
@testable import PaylikeEngine
import PaylikeRequest
import WebKit

class MockWebViewModel: WebViewModel {
    
    /*
     * Irrelevant for the test
     */
    var webView: WKWebView? = nil
    var shouldRenderWebView: Published<Bool> = .init(initialValue: false)
    var paylikeWebView: PaylikeWebView? = nil
    
    var requester = PaylikeHTTPClient()
    weak var _engine: PaylikeEngine?
    public var engine: (any Engine)? {
        return _engine
    }
    private var hintsListener: MockHintsListener? = nil
    private var cancellables: Set<AnyCancellable> = []
    
    let subPath1 = "/3dsecure/v2/tds-fingerprint-frame"
    let subPath2 = "/3dsecure/v2/terminate"
    let subPath3 = "/3dsecure/v2/tds-challenge-terminate"
    
    public init(engine: PaylikeEngine) {
        self._engine = engine
        requester.loggingFn = { _ in }
    }
    
    func createWebView() {
        hintsListener = MockHintsListener(webViewViewModel: self)
        setUpEngineListening()
    }
    
    func dropWebView() {
        hintsListener = nil
        cancellables = []
    }
    
    private func setUpEngineListening() {
        self._engine!.state.projectedValue
            .sink(receiveValue: { state in
                switch state {
                    case .WAITING_FOR_INPUT:
                        break
                    case .WEBVIEW_CHALLENGE_STARTED:
                        // webview js bridges to webViewModel and calls async, but we dont have webview now so we call it here
                        Task {
                            await MainActor.run {
                                var hints: [String] = []
                                self.jsCallbackToHintsListener(to: self.getMockURL(for: self.subPath1), completion: { hint in
                                    hints.append(hint)
                                    self.jsCallbackToHintsListener(to: self.getMockURL(for: self.subPath2), completion: { hint in
                                        hints.append(hint)
                                        hints.append(PaylikeEngineCreatePaymentTests.mockPaylikeServer.serverHints[5]) // cheating (not sure about one hint :) )
                                        self.hintsListener?.hintsListenerTrigger(hints: hints)
                                    })
                                })
                            }
                        }
                        break
                    case .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED:
                        // act like loading to webview
                        if PaylikeEngineCreatePaymentTests.mockPaylikeServer.htmlBodyString == self.engine?.repository.htmlRepository {
                            // debugPrint("HTML is right!")
                        }
                        // act like tds interaction
                        // debugPrint("User interaction!")
                        // then just continue
                        Task {
                            await MainActor.run {
                                self.jsCallbackToHintsListener(to: self.getMockURL(for: self.subPath3), completion: { hint in
                                    self.hintsListener?.hintsListenerTrigger(hints: [hint])
                                })
                            }
                        }
                        break
                    case .SUCCESS:
                        break
                    case .ERROR:
                        break
                }
                
            })
            .store(in: &cancellables)
    }
    
    /*
     * production implementation of this JS callback function is `userContentController`
     */
    func jsCallbackToHintsListener(to url: URL, completion: @escaping (String) -> Void) {
        requester.sendRequest(to: url, completion: { result in
            do {
                let response = try result.get()
                let body = String(data: response.data!, encoding: .utf8)!
                completion(body)
            } catch { }
        })
    }
    
    private func getMockURL(for subPath: String) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = MockScheme
        urlComponents.host = MockHost
        urlComponents.port = MockPort
        urlComponents.path = MockEndpoints.CREATE_PAYMENT_API.rawValue + subPath
        return  urlComponents.url!
    }
}
