import SwiftUI
import WebKit

struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var webViewModel = WebViewModel(url: "https://github.com")
    
    var body: some View {
        if E2E_DISABLED {
            Text("Merchant id is missing, without it the example application won't work.")
        } else {
            NavigationView {
                
                VStack() {
                    Text("\(viewModel.numberOfHints)")
                        .border(Color.purple)
                        .padding(10)
                    HStack {
                        Text("Transaction ID:")
                            .border(Color.pink)
                    }
                    .padding(10)
                    .frame(alignment: .center)
                    
                    
                    WebViewContainer(webViewModel: webViewModel)
                    
                    Spacer()
                    Button("Pay", action: {
                        print("Hello pay")
                    })
                    .padding(10)
                    .buttonStyle(.bordered)
                    .foregroundColor(Color.green)
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
}

/**
 * Previewing the current UI
 */
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
