import PaylikeEngine
import PaylikeClient
import PassKit
import _PassKit_SwiftUI
import Combine
import Foundation

class ViewModel: ObservableObject {
    
    /*
     * Const initial values for card payment
     */
    private let cardNumber = "4012111111111111"
    private let cvc = "111"
    private let month = 12
    private let year = 2030
    private let paymentAmount = PaymentAmount(currency: .HUF, value: 1, exponent: 0)
    private let paymentTest = PaymentTest(
//  Here we can add different test scenarios
//        card: TestCard(status: .DISABLED)
    )
    
    /*
     * Const initial values for card payment
     */
    let paymentHandler: PaymentHandler
    let request = PKPaymentRequest()

    /*
     * Reference object controlling the lower layers
     */
    @Published var paylikeEngine: PaylikeEngine
    private var cancellables: Set<AnyCancellable> = []
    
    /*
     * UI states
     * Specific example application state
     */
    @Published private (set) var viewModelState = ViewModelState.WAITING_FOR_INPUT
    @Published private (set) var shouldRenderWebView = false
    
    /*
     * UI states
     * Engine states saved here
     */
    @Published private (set) var engineState = EngineState.WAITING_FOR_INPUT
    @Published private (set) var transactionId: String? = nil
    @Published private (set) var authorizationId: String? = nil
    @Published private (set) var engineError: EngineErrorObject? = nil
    
    @Published var showingAlert: Bool = false
    @Published private (set) var alertTitle: String?
    @Published private (set) var alertDesc: String?

    /**
     * Initialization solely depending on the given engine
     *
     * @Default way is the given merchantId and test mode.
     */
    init(
        engine: PaylikeEngine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
    ) {
        self.paylikeEngine = engine
        self.paymentHandler = PaymentHandler(engine: engine)
        setupPaymentRequest()

        paylikeEngine.setLoggignMode(newMode: .RELEASE)

        self.cancellables.insert(
            engine.state.projectedValue
                .sink(receiveValue: { state in
                    if state != self.engineState {
                        Task {
                            await MainActor.run {
                                self.engineState = state
                                self.setViewModelState(newState: self.resolveUIState(from: state))
                                debugPrint("State sink, engineState: \(state)")
                            }
                        }
                    }
                    if self.paylikeEngine.repository.transactionId != self.transactionId {
                        Task {
                            await MainActor.run {
                                self.transactionId = self.paylikeEngine.repository.transactionId
                                debugPrint("Repo sink, transactionId: \(self.transactionId ?? "no transactionId yet")")
                            }
                        }
                    }
                    if self.paylikeEngine.repository.authorizationId != self.authorizationId {
                        Task {
                            await MainActor.run {
                                self.authorizationId = self.paylikeEngine.repository.authorizationId
                                debugPrint("Repo sink, authorizationId: \(self.authorizationId ?? "no authorizationId yet")")
                            }
                        }
                    }
                })
        )
        self.cancellables.insert(
            engine.error.projectedValue
                .sink(receiveValue: { error in
                    Task {
                        await MainActor.run {
                            self.engineError = error
                        }
                    }
                    if let error = error {
                        Task {
                            await MainActor.run {
                                self.alertTitle = "Error has occured"
                                self.alertDesc = ([error.clientError, error.engineError, error.httpClientError, error.webViewError] as [LocalizedError?])
                                    .compactMap { $0?.errorDescription }
                                    .first ?? ""
                                self.showingAlert = true
                                debugPrint("Error sink, error: \(error.message)")
                            }
                        }
                    }
                })
        )
        
        self.cancellables.insert(
            engine.webViewModel!.shouldRenderWebView.projectedValue
                .sink(receiveValue: { shouldRenderWebView in
                    if self.shouldRenderWebView != shouldRenderWebView {
                        Task {
                            await MainActor.run {
                                self.shouldRenderWebView = shouldRenderWebView
                            }
                        }
                    }
                })
        )
    }
    
    func setupAndStartPayment() {
        Task {
            await paylikeEngine.addEssentialPaymentData(cardNumber: cardNumber, cvc: cvc, month: month, year: year)
            paylikeEngine.addDescriptionPaymentData(paymentAmount: paymentAmount, paymentTestData: paymentTest)
            await paylikeEngine.startPayment()
        }
        setViewModelState(newState: .RUNNING)
    }
    func resetEngine() {
        Task {
            await MainActor.run {
                paylikeEngine.resetEngine()
            }
        }
    }
    
    func setViewModelState(newState: ViewModelState) {
        viewModelState = newState
    }
    
    private func resolveUIState(from engineState: EngineState) -> ViewModelState {
        return {
            switch engineState {
                case .WAITING_FOR_INPUT:
                    return .WAITING_FOR_INPUT
                case .WEBVIEW_CHALLENGE_STARTED,
                        .WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED:
                    return .RUNNING
                case .SUCCESS,
                        .ERROR:
                    return .SUCCESS_OR_ERROR
            }
        }()
    }
    
    private func setupPaymentRequest() {
        let total = PKPaymentSummaryItem(label: "Total", amount: 1, type: .final)
        request.merchantIdentifier = merchantId
        request.merchantCapabilities = [.capability3DS, .capabilityEMV]
        request.countryCode = "HU"
        request.paymentSummaryItems = [total]
        request.currencyCode = CurrencyCodes.HUF.rawValue
        request.supportedNetworks = [.visa, .masterCard, .maestro]
        request.paymentSummaryItems = [.init(label: "Test Company recieving the payment", amount: .one, type: .final)]
    }
}
