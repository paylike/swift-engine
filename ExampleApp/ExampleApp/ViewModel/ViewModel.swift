import PaylikeEngine
import Foundation

/**
 * 
 */
extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        
        var paylikeEngine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
        
        @Published var shouldRenderPayButton: Bool = true
        @Published var shouldRenderWebView: Bool = false

        @Published var transactionId: String?
        @Published var error: Error?
        @Published var numberOfHints: Int = 0
    }
}
