import PaylikeClient
import PaylikeRequest
import Foundation

/**
 * Paylike engine wrapper class to support Paylike transactions towards the API
 */
public class PaylikeEngine: ObservableObject {
    
    public var merchantID: String
    
    public var client = PaylikeClient()
    
    public var webViewModel: (any WebViewModel)?
    
    public var engineMode = EngineMode.TEST
    
    public var loggingMode = LoggingMode.DEBUG
    
    public var loggingFn: ((Encodable) -> Void) = { obj in
        print("Engine logger:", terminator: " ")
        debugPrint(obj)
    }
    
    @Published internal(set) public var state = EngineState.WAITING_FOR_INPUT
    @Published internal(set) public var error: EngineErrorObject?
    @Published internal(set) public var repository = EngineReposity()

    public init(
        merchantID: String,
        engineMode: EngineMode,
        loggingMode: LoggingMode = .DEBUG
    ) {
        self.merchantID = merchantID
        self.engineMode = engineMode
        setLoggignMode(newMode: loggingMode)
        webViewModel = PaylikeWebViewModel(engine: self)
    }
    
    public func setLoggignMode(newMode: LoggingMode) {
        loggingMode = newMode
        setLoggerFns(basedOn: newMode)
    }
    private func setLoggerFns(basedOn engineMode: LoggingMode) {
        switch engineMode {
            case .DEBUG:
                loggingFn = { obj in
                    print("Engine logger:", terminator: " ")
                    debugPrint(obj)
                }
                client.loggingFn = { obj in
                    print("Client logger:", terminator: " ")
                    debugPrint(obj)
                }
                client.httpClient.loggingFn = { obj in
                    print("HTTP Client logger:", terminator: " ")
                    debugPrint(obj)
                }
            case .RELEASE:
                loggingFn = { _ in }
                client.loggingFn = { _ in }
                client.httpClient.loggingFn = { _ in }
        }
    }
}
