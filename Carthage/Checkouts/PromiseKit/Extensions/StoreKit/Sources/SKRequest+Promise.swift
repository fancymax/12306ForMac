import StoreKit
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `SKRequest` category:

    use_frameworks!
    pod "PromiseKit/StoreKit"

 And then in your sources:

    import PromiseKit
*/
extension SKRequest {
    /**
     Sends the request to the Apple App Store.

     - Returns: A promise that fulfills if the request succeeds.
    */
    public func promise() -> Promise<SKProductsResponse> {
        let proxy = SKDelegate()
        delegate = proxy
        proxy.retainCycle = proxy
        start()
        return proxy.promise
    }
}


private class SKDelegate: NSObject, SKProductsRequestDelegate {
    let (promise, fulfill, reject) = Promise<SKProductsResponse>.pending()
    var retainCycle: SKDelegate?

    @objc fileprivate func request(_ request: SKRequest, didFailWithError error: Error) {
        reject(error)
        retainCycle = nil
    }

    @objc fileprivate func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        fulfill(response)
        retainCycle = nil
    }

    @objc override class func initialize() {
        NSError.registerCancelledErrorDomain(SKErrorDomain, code: SKError.Code.paymentCancelled.rawValue)
    }
}
