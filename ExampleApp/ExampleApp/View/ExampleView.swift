import PaylikeEngine
import PaylikeClient
import SwiftUI
import WebKit

struct ExampleView: View {
    
    @StateObject private var viewModel = ViewModel(engine: PaylikeEngine(merchantID: merchantId, engineMode: .TEST))

    var body: some View {
        if E2E_DISABLED {
            Text("Merchant id is missing, without it the example application won't work.")
        } else {
            NavigationView {
                VStack() {
                    VStack {
                        Text("\(viewModel.hintsNumber)")
                            .border(Color.purple)
                        Text("State: \(viewModel.engineState.rawValue)")
                            .border(Color.pink)
                        Text("Transaction ID: \(viewModel.transactionId ?? (viewModel.authorizationId ?? "No transactionId nor authorizationId"))")
                            .border(Color.pink)
                    }
                    .padding(10)
                    .frame(alignment: .center)
                    
                    if viewModel.paylikeEngine.webViewModel!.shouldRenderWebView {
                        viewModel.paylikeEngine.webViewModel!.paylikeWebView
                            .frame(maxWidth: .infinity, maxHeight: 400, alignment: .center)
                            .border(Color.black)
                    }
                    
                    Spacer()
                    
                    if viewModel.viewModelState == .WAITING_FOR_INPUT {
                        Button("Pay", action: viewModel.setupAndStartPayment)
                            .padding(10)
                            .buttonStyle(.bordered)
                            .foregroundColor(Color.green)
                    } else if viewModel.viewModelState == .SUCCESS_OR_ERROR {
                        Button("Reset", action: viewModel.resetEngine)
                            .padding(10)
                            .buttonStyle(.bordered)
                            .foregroundColor(Color.green)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .border(Color.black)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("Pay with Paylike")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue)
                    }
                }
            }
            .border(Color.green)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
//    internal struct Content: View {
//
//        var viewModel: ViewModel
//
////        init(viewModel: ViewModel) {
////            self.viewModel = viewModel
////        }
//
//        var body: some View {
//            NavigationView {
//                VStack() {
//
//                    FeedBackTextFields(viewModel: viewModel)
//
//                    if viewModel.shouldRenderWebView {
//                        viewModel.paylikeWebViewModel.paylikeWebview
//                            .frame(maxWidth: .infinity, maxHeight: 500, alignment: .center)
//                    } else {
//                        Text("No webview yet")
//                            .frame(maxWidth: .infinity, maxHeight: 500, alignment: .center)
//                    }
//
//                    Spacer()
//
//                    if viewModel.shouldRenderPayButton {
//                        PaylikeButton(text: "Pay", action: viewModel.setupAndStartPayment)
//                    } else if viewModel.shouldRenderResetButton {
//                        PaylikeButton(text: "Reset", action: viewModel.resetEngine)
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                .border(Color.black)
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        HStack(alignment: .center, spacing: 0) {
//                            Text("Pay with Paylike")
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        }
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Color.blue)
//                    }
//                }
//            }
//            .border(Color.green)
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//        }
//    }
//
//    private struct FeedBackTextFields: View {
//
//        var viewModel: ViewModel
//
//        var body: some View {
//            VStack {
//                if let count = viewModel.paylikeEngine.repository.paymentRepository?.hints.count {
//                    Text("\(count)")
//                        .border(Color.purple)
//                } else {
//                    Text("Nil hints.")
//                        .border(Color.purple)
//                }
//                Text("State: \(viewModel.paylikeEngine.state.rawValue)")
//                    .border(Color.pink)
//                Text("Transaction ID: \(viewModel.paylikeEngine.repository.transactionId ?? "No transaction id yet")")
//                    .border(Color.pink)
//            }
//            .padding(10)
//            .frame(alignment: .center)
//        }
//    }
//
//    private struct PaylikeButton: View {
//
//        let text: String
//        let action: () -> Void
//
//        var body: some View {
//            Button(text, action: action)
//                .padding(10)
//                .buttonStyle(.bordered)
//                .foregroundColor(Color.green)
//        }
//    }
}

/**
 * Previewing the current UI
 */
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
