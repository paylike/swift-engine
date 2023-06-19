import PassKit
import SwiftUI

struct ApplePayButton: View {
    
    let paymentHandler: PaymentHandler
    
    var body: some View {
        Button(action: {
            self.paymentHandler.startPayment { success in
                if success {
                    print("success")
                } else {
                    print("failure")
                }
            }
        }, label: { EmptyView() } )
        .buttonStyle(PaymentButtonStyle())
    }
}

struct PaymentButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return PaymentButtonHelper()
    }
}

struct PaymentButtonHelper: View {
    var body: some View {
        PaymentButtonRepresentable()
            .frame(minWidth: 100, maxWidth: 400)
    }
}

extension PaymentButtonHelper {
    struct PaymentButtonRepresentable: UIViewRepresentable {
        
        var button: PKPaymentButton {
            let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .white)
            button.cornerRadius = 4.0
            return button
        }
        
        func makeUIView(context: Context) -> PKPaymentButton {
            return button
        }
        func updateUIView(_ uiView: PKPaymentButton, context: Context) { }
    }
}
