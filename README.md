# PaylikeEngine

[![build_test](/../../actions/workflows/build_test.yml/badge.svg?branch=main)](/../../actions/workflows/build_test.yml)

This library includes the core elements required to implement a payment flow towards the Paylike API.
If you are looking for our high level component providing complete payment forms as well, [check here](https://github.com/paylike/swift-sdk).

## Table of contents
* [API Reference](#api-reference)
* [PaylikeEngine](#paylikeengine) (Underlying business logic service)
    * [Engine events](#engine-events)
* [PaylikeWebView](#paylikeWebView) (WebView composable)
    * [Understanding 3D Secure](#understanding-tds)
* [Sample application](#sample-application)

## API Reference

For the library you can find the API reference [here](https://paylike.io/integration/documentation).
To get more familiar with our server API you can find here the [official documentation](https://github.com/paylike/api-reference).

## PaylikeEngine

The core component of the payment flow.
Essentially designed to be event based to allow as much flexibility as possible on the user side.

Example payment initiation using card:
```swift
val engine = PaylikeEngine(
    merchantID: "merchantId", // your own merchant ID
    engineMode: .TEST 
    )

let cardNumber = "4012111111111111"
let cvc = "111"
let month = 12
let year = 2030
let paymentAmount = PaymentAmount(currency: .HUF, value: 1, exponent: 0)
let paymentTest = PaymentTest() // in case of `.TEST` engineMode it is needed to include `PaymentTest` data

/*
 * After the `startPayment()` function the engine updates it's state to render TDS webView challenge.
 * A `engine.webViewModel` instance listens to the states of the engine,
 * so it can manage the TDS challenge flow.
 */
Task {
    await paylikeEngine.addEssentialPaymentData(cardNumber: cardNumber, cvc: cvc, month: month, year: year)
    paylikeEngine.addDescriptionPaymentData(paymentAmount: paymentAmount, paymentTestData: paymentTest)
    await paylikeEngine.startPayment()
}
```

### Engine events

The library exposes an enum called EngineState which describes the following states:

- WAITING_FOR_INPUT - Indicates that the engine is ready to be used and waiting for input
- WEBVIEW_CHALLENGE_STARTED - Indicates that a webView challenge is required to complete the TDS flow, this is the first state when the webView has to be rendered
- WEBVIEW_CHALLENGE_USER_INPUT_REQUIRED - Indicates that the first step of the TDS flow is done and the challenge needs interraction from the end user to resolve
- SUCCESS - Indicates that all challenges are done successfully and the payment is being processed
- ERROR - Happens when the flow could not be completed successfully

## PaylikeWebView

WebView component of the payment flow, able to render the webView required to execute the TDS challenge.
It is provided by the PaylikeEngine instance, and it takes care of it's lifecycle.
The webView implementation can be redefined and changed in PaylikeEngine by conforming to `WebViewModel` protocol and add it to the engine runtime.

Simplified usage:
```swift
import PaylikeEngine

struct ExampleView: View {
    
    @StateObject private var engine = PaylikeEngine(merchantID: "merchantId", engineMode: .TEST)

    var body: some View {
        if engine.webViewModel!.shouldRenderWebView {
            engine.webViewModel!.paylikeWebView
                .frame(height: height, width: width)
        }
    }
}
```

For testing usage check out the example [here](/#sample-application).

### Understanding 3D Secure

3D Secure is required to execute the payment flow and it is a core part of accepting payments online. Every bank is required by financial laws to provide this methodology for their customers in order to achieve higher security measures.

## Sample application

In the [example directory](/tree/main/ExampleApp) you can find a simple application which show how to use the library.

You need to [register a merchant account](https://paylike.io/sign-up) with Paylike before you can use the sample application. Once you have created your account you can create a new client ID for yourself and use it in the sandbox environment.

You have to enter your client ID to `merchantId` to initiate payment successfully in the example app.
