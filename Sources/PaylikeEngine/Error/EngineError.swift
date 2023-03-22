import Foundation

/**
 Describes errors regarding the library
 */
public enum EngineError : Error {
    case UnimplementedError
    
    case InvalidEngineState(caller: String, actual: EngineState, expected: EngineState)
    case PaymentRespositoryIsNotInitialised
    case EssentialPaymentRepositoryDataFailure(hasBoth: Bool)
    case InvalidCardNumber(cardNumber: String)
    case WrongAmountOfHints(actual: Int, expected: Int)
    case CardNumberIsInvalid(String)
    case PaymentFlowError(caller: String, cause: String)
}

extension EngineError : LocalizedError {
    public var errorDescription: String? {
        switch self {
                
            case .UnimplementedError:
                return "Unimplemented"
                
                
                
            case .InvalidEngineState(let caller, let actual, let expected):
                return "Can't call \(caller) in this state: \(actual). The valid state now is \(expected)."
            case .PaymentRespositoryIsNotInitialised:
                return "`CreatePaymentRequest` is not initialised."
            case .EssentialPaymentRepositoryDataFailure(let hasBoth):
                return hasBoth ? "Exists both of the data" : "PaymentCard or Apple pay data is missing."
            case .InvalidCardNumber(let cardNumber):
                return "Invalid card number: \(cardNumber)"
            case .WrongAmountOfHints(let actual, let expected):
                return "Expected number: \(expected). Actual number: \(actual)."
            case .CardNumberIsInvalid(let cardNubmer):
                return "\(cardNubmer) is invalid based on Luhn algorithm"
            case .PaymentFlowError(let caller, let cause):
                return "Payment flow error in \(caller). Error caused by: \(cause)"
        }
    }
}
