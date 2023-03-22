import PaylikeClient
import PaylikeLuhn
import AnyCodable

/**
 *
 */
extension PaylikeEngine {
    
    /**
     *
     */
    public func addEssentialPaymentData(
        applePayToken: String
    ) async {
        do {
            try checkValidState(valid: EngineState.WAITING_FOR_INPUT, callerFunc: #function)
            
            async let applePayToken = paylikeClient.tokenize(applePayData: TokenizeApplePayDataRequest(token: applePayToken))
            
            initialisePaymentRepositoryIfNil()
            repository.paymentRepository!.applepay = try await applePayToken
        } catch {
            setErrorState(e: error)
        }
    }
    
    /**
     * Execute api calls and create the necessary data for the [EngineRepository.paymentRepository]
     * /(PaylikeCard)
     * These are: [PaylikeCard], [PaymentIntegration
     * @see <a
     * href="https://github.com/paylike/api-reference/blob/main/payments/index.md#challengeresponse">Api
     * Docs</a>
     */
    public func addEssentialPaymentData(
        cardNumber: String,
        cvc: String,
        month: Int,
        year: Int
    ) async {
        do {
            try checkValidState(valid: EngineState.WAITING_FOR_INPUT, callerFunc: #function)
            if  !PaylikeLuhn.isValid(cardNumber: cardNumber)
                    && engineMode == EngineMode.LIVE {
                throw EngineError.InvalidCardNumber(cardNumber: cardNumber)
            }
            async let numberToken = paylikeClient.tokenize(cardData: TokenizeCardDataRequest(type: .PCN, value: cardNumber))
            async let cvcToken = paylikeClient.tokenize(cardData: TokenizeCardDataRequest(type: .PCSC, value: cvc))
            
            let card = try await PaymentCard(number: numberToken, code: cvcToken, expiry: CardExpiry(month: month, year: year))
            
            initialisePaymentRepositoryIfNil()
            repository.paymentRepository!.card = card
        } catch {
            setErrorState(e: error)
        }
    }
    
    
    
    /**
     * These fields describe the payment characteristics. To set up check the api docs below.
     * @param paymentAmount define a single payment amount
     * @param paymentPlanDataList define reoccurring payments
     * @param paymentUnplannedData define the types of unplanned payments the card will be used for
     * @see <a
     * href="https://github.com/paylike/api-reference/blob/main/payments/index.md#challengeresponse">Api
     * Docs</a>
     */
    public func addDescriptionPaymentData(
        paymentAmount: PaymentAmount? = nil,
        paymentPlanDataList: [PaymentPlan]? = nil,
        paymentUnplannedData: PaymentUnplanned? = nil,
        paymentTestData: PaymentTest? = nil
    ) {
        do {
            try checkValidState(valid: EngineState.WAITING_FOR_INPUT, callerFunc: #function)
            initialisePaymentRepositoryIfNil()
            repository.paymentRepository!.amount = paymentAmount
            repository.paymentRepository!.plan = paymentPlanDataList
            repository.paymentRepository!.unplanned = paymentUnplannedData
            repository.paymentRepository!.test = paymentTestData
        } catch {
            setErrorState(e: error)
        }
    }
    
    /**
     * These field are optional to define.
     * @param textData is a simple text shown on the paylike dashboard
     * @param customData is a custom Json object defined by the user
     * @see <a
     * href="https://github.com/paylike/api-reference/blob/main/payments/index.md#challengeresponse">Api
     * Docs</a>
     */
    public func addAdditionalPaymentData(
        textData: String? = nil,
        customData: AnyEncodable? = nil
    ) {
        do {
            try checkValidState(valid: EngineState.WAITING_FOR_INPUT, callerFunc: #function)
            initialisePaymentRepositoryIfNil()
            repository.paymentRepository!.text = textData
            repository.paymentRepository!.custom = customData
        } catch {
            setErrorState(e: error)
        }
    }
}
