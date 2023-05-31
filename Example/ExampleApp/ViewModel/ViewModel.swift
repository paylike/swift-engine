import PaylikeEngine
import PaylikeClient
import PassKit
import _PassKit_SwiftUI
import Combine
import Foundation

/**
 *
 */
internal class ViewModel: ObservableObject {
    
    /*
     * Const initial values for card payment
     */
    private let cardNumber = "4012111111111111"
    private let cvc = "111"
    private let month = 12
    private let year = 2030
    private let paymentAmount = PaymentAmount(currency: .HUF, value: 1, exponent: 0)
    private let paymentTest = PaymentTest(
        card: TestCard(status: .DISABLED)
    )
    
    /*
     * Const initial values for card payment
     */
    let paymentHandler: PaymentHandler
    let request = PKPaymentRequest()

    /*
     * Reference object controlling the lower layers
     */
    @Published internal var paylikeEngine: PaylikeEngine
    private var cancellables: Set<AnyCancellable> = []
    
    /*
     * UI states
     * Specific example application state
     */
    @Published private (set) internal var viewModelState = ViewModelState.WAITING_FOR_INPUT
    
    /*
     * UI states
     * Engine states saved here
     */
    @Published private (set) internal var engineState = EngineState.WAITING_FOR_INPUT
    @Published private (set) internal var hintsNumber = 0
    @Published private (set) internal var transactionId: String? = nil
    @Published private (set) internal var authorizationId: String? = nil
    @Published private (set) internal var engineError: EngineErrorObject? = nil
    @Published internal var showingAlert: Bool = false
    @Published internal var alertTitle: String?
    @Published internal var alertDesc: String?

    /**
     * Initialization solely depending on the given engine
     * @Default way is the given merchantId and test mode.
     */
    init(
        engine: PaylikeEngine = PaylikeEngine(merchantID: merchantId, engineMode: .TEST)
    ) {
        self.paylikeEngine = engine
        self.cancellables = []
        self.paymentHandler = PaymentHandler(engine: engine)
        setupPaymentRequest()

        
        paylikeEngine.client.httpClient.loggingFn = { _ in }
        paylikeEngine.client.loggingFn = { _ in }
    
        self.cancellables.insert(
            $paylikeEngine.sink(
                receiveValue: { engine in
                    self.objectWillChange.send()
                    self.cancellables.insert(
                        engine.$state
                            .sink(receiveValue: { state in
                                if state != self.engineState {
                                    self.engineState = state
                                    self.setViewModelState(newState: self.resolveUIState(from: state))
                                    debugPrint("State sink, engineState: \(state)")
                                    debugPrint("State sink, UIState: \(state)")
                                }
                            })
                    )
                    self.cancellables.insert(
                        engine.$error
                            .sink(receiveValue: { error in
                                self.engineError = error
                                if let error = error {
                                    self.alertTitle = "Error has occured"
                                    self.alertDesc = ([error.clientError, error.engineError, error.httpClientError, error.webViewError] as [LocalizedError?])
                                        .compactMap { $0?.errorDescription }
                                        .first ?? ""
                                    self.showingAlert = true
                                }
                                debugPrint("Error sink, error: \(error?.message ?? "nil")")
                            })
                    )
                    self.cancellables.insert(
                        engine.$repository
                            .sink(receiveValue: { repo in
                                if (repo.paymentRepository?.hints.count ?? 0) != self.hintsNumber {
                                    self.hintsNumber = (repo.paymentRepository?.hints.count ?? 0)
                                    debugPrint("Repo sink, hints: \(self.hintsNumber)")
                                }
                                if repo.transactionId != self.transactionId {
                                    self.transactionId = repo.transactionId
                                    debugPrint("Repo sink, transactionId: \(self.transactionId ?? "no transactionId yet")")
                                }
                                if repo.authorizationId != self.authorizationId {
                                    self.authorizationId = repo.authorizationId
                                    debugPrint("Repo sink, authorizationId: \(self.authorizationId ?? "no authorizationId yet")")
                                }
                            })
                    )
                }
            )
        )
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
    
    /*
     * Engine handling functions
     */
    public func setupAndStartPayment() {
        Task {
            await paylikeEngine.addEssentialPaymentData(cardNumber: cardNumber, cvc: cvc, month: month, year: year)
            paylikeEngine.addDescriptionPaymentData(paymentAmount: paymentAmount, paymentTestData: paymentTest)
            await paylikeEngine.startPayment()
        }
        setViewModelState(newState: .RUNNING)
    }
    public func resetEngine() {
        paylikeEngine.resetEngine()
    }
    
    /*
     * UI state handling public functions
     */
    public func setViewModelState(newState: ViewModelState) {
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
}
