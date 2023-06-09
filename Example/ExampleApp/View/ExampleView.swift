import PaylikeEngine
import PaylikeClient
import PassKit
import SwiftUI
import WebKit

struct ExampleView: View {
    @StateObject private var viewModel = ViewModel(engine: PaylikeEngine(merchantID: merchantId, engineMode: .TEST))
    
    var body: some View {
        NavigationView {
            VStack {
                if E2E_DISABLED {
                    Text("Merchant id is missing, without it the example application won't work.")
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("State: ")
                                .padding(1)
                            Text("Transaction ID: ")
                                .padding(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(viewModel.engineState.rawValue)")
                                .padding(1)
                                .lineLimit(1)
                            Text("\(viewModel.transactionId ?? (viewModel.authorizationId ?? "nil"))")
                                .padding(1)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
                    if viewModel.shouldRenderWebView {
                        viewModel.paylikeEngine.webViewModel!.paylikeWebView
                            .frame(maxWidth: .infinity, maxHeight: 400, alignment: .center)
                    }
                    Spacer()
                    VStack {
                        if viewModel.viewModelState == .WAITING_FOR_INPUT {
                            Button("Pay with card data", action: viewModel.setupAndStartPayment)
                                .buttonStyle(PaylikeButtonStyle())
                            ApplePayButton(paymentHandler: viewModel.paymentHandler)
                                .frame(width: 200, height: 40)
                        } else if viewModel.viewModelState == .SUCCESS_OR_ERROR {
                            Button("Reset", action: viewModel.resetEngine)
                                .buttonStyle(PaylikeButtonStyle())
                        }
                    }
                    .padding(10)
                }
            }
            .navigationTitle("Pay with Paylike")
        }
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(title: Text(viewModel.alertTitle!),
                  message: Text(viewModel.alertDesc!),
                  dismissButton: .default(Text("Dismiss"))
            )
        }
    }
}

struct PaylikeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 200, height: 40)
            .frame(maxWidth: 200)
            .background(Color.accentColor)
            .foregroundColor(Color.primary)
            .cornerRadius(4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
