import PMKStoreKit
import PromiseKit
import StoreKit
import XCTest

class SKProductsRequestTests: XCTestCase {
    func test() {
        class MockProductsRequest: SKProductsRequest {
            override func start() {
                after(interval: 0.1).then {
                    self.delegate?.productsRequest(self, didReceive: SKProductsResponse())
                }
            }
        }

        let ex = expectation(description: "")
        MockProductsRequest().promise().then { _ in
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCancellation() {
        class MockProductsRequest: SKProductsRequest {
            override func start() {
                after(interval: 0.1).then { _ -> Void in
                    let err = NSError(domain: SKErrorDomain, code: SKError.Code.paymentCancelled.rawValue, userInfo: nil)
                    self.delegate?.request?(self, didFailWithError: err)
                }
            }
        }

        let ex = expectation(description: "")
        MockProductsRequest().promise().catch(policy: .allErrors) { err in
            XCTAssert((err as NSError).isCancelled)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
