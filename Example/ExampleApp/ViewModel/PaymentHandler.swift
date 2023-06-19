import PaylikeClient
import PaylikeEngine
import PassKit

typealias PaymentCompletionHandler = (Bool) -> Void

class PaymentHandler: NSObject {
    var engine: PaylikeEngine
    
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: PaymentCompletionHandler?
    
    init(engine: PaylikeEngine) {
        self.engine = engine
    }
    
    func startPayment(completion: @escaping PaymentCompletionHandler) {
        completionHandler = completion
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = [.init(label: "Test Company recieving the payment", amount: .one, type: .final)]
        paymentRequest.merchantIdentifier = applePayMerchantId
        paymentRequest.countryCode = "HU"
        paymentRequest.currencyCode = CurrencyCodes.HUF.rawValue
        paymentRequest.merchantCapabilities = [.capability3DS]
        paymentRequest.supportedNetworks = [.visa, .masterCard, .maestro]
        
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                // nothing
            } else {
                self.completionHandler!(false)
            }
        })
    }
}

/*
 * PKPaymentAuthorizationControllerDelegate conformance.
 */
extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        Task {
            if
                let token = String(data: payment.token.paymentData, encoding: .utf8)
            {
                await engine.addEssentialPaymentData(applePayToken: token)
                engine.addAdditionalPaymentData(textData: "From Apple Pay")
                engine.addDescriptionPaymentData(paymentAmount: try! PaymentAmount(currency: CurrencyCodes.HUF, double: 1.0), paymentTestData: PaymentTest())
                await engine.startPayment()
            } else {
                engine.prepareError(EngineError.NotImplemented)
                paymentStatus = .failure
            }
            completion(paymentStatus)
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.completionHandler!(true)
                } else {
                    self.completionHandler!(false)
                }
            }
        }
    }
}

/**
 * Temporary applePay payload DTO
 */
struct ApplePayToken: Decodable {
    let data: String?
    let header: Header?
    let signature: String?
    let version: String?
}

/**
 * Temporary applePay payload DTO
 */
struct Header: Decodable {
    let publicKeyHash: String?
    let ephemeralPublicKey: String?
    let transactionId: String?
}
