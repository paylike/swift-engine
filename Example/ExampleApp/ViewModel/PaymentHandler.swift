import PaylikeClient
import PaylikeEngine
import PassKit

typealias PaymentCompletionHandler = (Bool) -> Void

class PaymentHandler: NSObject {
    
    public init(engine: PaylikeEngine) {
        self.engine = engine
    }
    
    var engine: PaylikeEngine
    
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: PaymentCompletionHandler?
    
    func startPayment(completion: @escaping PaymentCompletionHandler) {
        
        completionHandler = completion
        
        // Create our payment request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = [.init(label: "Test Company recieving the payment", amount: .one, type: .final)]
        paymentRequest.merchantIdentifier = applePayMerchantId
        paymentRequest.countryCode = "HU"
        paymentRequest.currencyCode = CurrencyCodes.HUF.rawValue
        paymentRequest.merchantCapabilities = [.capability3DS]
        paymentRequest.supportedNetworks = [.visa, .masterCard, .maestro]
        //        paymentRequest.requiredShippingContactFields = [.phoneNumber, .emailAddress]

        
        // Display our payment request
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                NSLog("Presented payment controller")
            } else {
                NSLog("Failed to present payment controller")
                self.completionHandler!(false)
            }
        })
    }
}

/*
 PKPaymentAuthorizationControllerDelegate conformance.
 */
extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {
    
    
    
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        // Perform some very basic validation on the provided contact information
//        if payment.shippingContact?.emailAddress == nil || payment.shippingContact?.phoneNumber == nil {
//            paymentStatus = .failure
//        } else {
            // Here you would send the payment token to your server or payment provider to process
            // Once processed, return an appropriate status in the completion handler (success, failure, etc)
//            paymentStatus = .success
//        }
        
        Task {
            
            
            debugPrint("applePayToken payment: \(payment)")

            
            if
                let token2 = String(data: payment.token.paymentData, encoding: .utf8),
                let token = try? JSONDecoder().decode(ApplePayToken.self, from: payment.token.paymentData),
                let data = token.data
            {
//                debugPrint("applePayToken token: \(token)")
//                debugPrint("applePayToken data: \(data)")
                debugPrint("applePayToken: \(token2)")


                await engine.addEssentialPaymentData(applePayToken: token2)
                engine.addAdditionalPaymentData(textData: "From Apple Pay")
                engine.addDescriptionPaymentData(paymentAmount: try! PaymentAmount(currency: CurrencyCodes.HUF, double: 1.0), paymentTestData: PaymentTest())
                
                await engine.startPayment()
                
                NSLog("hello comp in paymentauthorizationController")
                
            } else {
                NSLog("hello fail in paymentauthorizationController")
                paymentStatus = .failure
            }
            completion(paymentStatus)
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    NSLog("hello comp in didfinish")
                    self.completionHandler!(true)
                } else {
                    NSLog("hello fail in didfinish")
                    self.completionHandler!(false)
                }
            }
        }
    }
    
}


struct ApplePayToken: Decodable {
    let data: String?
    let header: Header?
    let signature: String?
    let version: String?
}

struct Header: Decodable {
    let publicKeyHash: String?
    let ephemeralPublicKey: String?
    let transactionId: String?
}
