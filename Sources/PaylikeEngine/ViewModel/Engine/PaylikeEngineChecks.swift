extension PaylikeEngine {
    
    func checkValidState(valid state: EngineState, callerFunc: String) throws {
        guard self.internalState == state else {
            throw EngineError.InvalidEngineState(caller: callerFunc, actual: self.internalState, expected: state)
        }
    }
    
    func areEssentialPaymentRepositoryFieldsAdded() throws {
        try isPaymentRepositoryInitialised()
        
        let hasCard = repository.paymentRepository!.card != nil
        let hasApplePay = repository.paymentRepository!.applepay != nil
        guard hasCard != hasApplePay
        else {
            throw EngineError.EssentialPaymentRepositoryDataFailure(hasBoth: hasCard && hasApplePay)
        }
    }
    
    func isNumberOfHintsRight() throws {
        try isPaymentRepositoryInitialised()
        let actual = repository.paymentRepository!.hints.count
        let expected = EngineState.getNumberOfExpectedHints(state: self.internalState)
        guard actual == expected else {
            throw EngineError.WrongAmountOfHints(actual: actual, expected: expected)
        }
    }
    
    func isPaymentRepositoryInitialised() throws {
        guard repository.paymentRepository != nil else {
            throw EngineError.PaymentRespositoryIsNotInitialised
        }
    }
}
