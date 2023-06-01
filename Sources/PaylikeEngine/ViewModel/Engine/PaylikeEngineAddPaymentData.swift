import PaylikeClient
import PaylikeLuhn
import AnyCodable

extension PaylikeEngine {
    
    /**
     * Adding the generated applePay token to Paylike backend to tokenize it.
     *
     * Stores the tokenized applePay token to the engine PaymentRepository.
     * [More information](https://github.com/paylike/api-reference/blob/main/payments/index.md)
     */
    final public func addEssentialPaymentData(
        applePayToken: String
    ) async {
        do {
            try checkValidState(valid: EngineState.WAITING_FOR_INPUT, callerFunc: #function)
            var paymentRepository = initialisePaymentRepositoryIfNil()
            
            async let applePayToken = client.tokenize(applePayData: TokenizeApplePayDataRequest(token: applePayToken))
            paymentRepository.applepay = try await applePayToken
            
            await savePaymentRepository(newRepository: paymentRepository)
        } catch {
            prepareError(e: error)
        }
    }
    
    /**
     * Adding the card data to Paylike backend to tokenize it.
     *
     * Stores the tokenized data to the engine PaymentRepository.
     * [More information](https://github.com/paylike/api-reference/blob/main/payments/index.md)
     */
    public func addEssentialPaymentData(
        cardNumber: String,
        cvc: String,
        month: Int,
        year: Int
    ) async {
        do {
            try await addEssentialPaymentData(
                cardNumber: cardNumber,
                cvc: cvc,
                expiry: CardExpiry(month: month, year: year)
            )
        } catch {
            prepareError(e: error)
        }
    }
    
    /**
     * Adding the card data to Paylike backend to tokenize it.
     *
     * Stores the tokenized data to the engine PaymentRepository.
     * [More information](https://github.com/paylike/api-reference/blob/main/payments/index.md)
     */
    public func addEssentialPaymentData(
        cardNumber: String,
        cvc: String,
        expiry: CardExpiry
    ) async {
        do {
            try checkValidState(valid: EngineState.WAITING_FOR_INPUT, callerFunc: #function)
            var paymentRepository = initialisePaymentRepositoryIfNil()

            if  !PaylikeLuhn.isValid(cardNumber: cardNumber)
                    && engineMode == .LIVE {
                throw EngineError.InvalidCardNumber(cardNumber: cardNumber)
            }
            async let numberToken = client.tokenize(cardData: TokenizeCardDataRequest(type: .PCN, value: cardNumber))
            async let cvcToken = client.tokenize(cardData: TokenizeCardDataRequest(type: .PCSC, value: cvc))
            let card = try await PaymentCard(number: numberToken, code: cvcToken, expiry: expiry)
            paymentRepository.card = card
                    
            await savePaymentRepository(newRepository: paymentRepository)
        } catch {
            prepareError(e: error)
        }
    }
    
    /**
     * These fields describe the payment characteristics. To set up check the api docs below.
     * @param paymentAmount define a single payment amount
     * @param paymentPlanDataList define reoccurring payments
     * @param paymentUnplannedData define the types of unplanned payments the card will be used for
     * [More information](https://github.com/paylike/api-reference/blob/main/payments/index.md)
     */
    public func addDescriptionPaymentData(
        paymentAmount: PaymentAmount? = nil,
        paymentPlanDataList: [PaymentPlan]? = nil,
        paymentUnplannedData: PaymentUnplanned? = nil,
        paymentTestData: PaymentTest? = nil
    ) {
        do {
            try checkValidState(valid: EngineState.WAITING_FOR_INPUT, callerFunc: #function)
            var paymentRepository = initialisePaymentRepositoryIfNil()
            
            paymentRepository.amount = paymentAmount
            paymentRepository.plan = paymentPlanDataList
            paymentRepository.unplanned = paymentUnplannedData
            paymentRepository.test = paymentTestData
            
            savePaymentRepository(newRepository: paymentRepository)
        } catch {
            prepareError(e: error)
        }
    }
    
    /**
     * These field are optional to define.
     * @param textData is a simple text shown on the paylike dashboard
     * @param customData is a custom Json object defined by the user
     * [More information](https://github.com/paylike/api-reference/blob/main/payments/index.md)
     */
    public func addAdditionalPaymentData(
        textData: String? = nil,
        customData: AnyEncodable? = nil
    ) {
        do {
            try checkValidState(valid: EngineState.WAITING_FOR_INPUT, callerFunc: #function)
            var paymentRepository = initialisePaymentRepositoryIfNil()
            
            paymentRepository.text = textData
            paymentRepository.custom = customData
            
            savePaymentRepository(newRepository: paymentRepository)
        } catch {
            prepareError(e: error)
        }
    }
    
    private func initialisePaymentRepositoryIfNil() -> CreatePaymentRequest {
        return repository.paymentRepository ?? CreatePaymentRequest(merchantID: PaymentIntegration(merchantId: self.merchantID))
    }
}
