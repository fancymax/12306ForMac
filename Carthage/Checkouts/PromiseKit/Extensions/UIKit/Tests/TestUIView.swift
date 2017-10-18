import PromiseKit
import PMKUIKit
import XCTest
import UIKit

class UIViewTests: XCTestCase {
    func test() {
        let ex1 = expectation(description: "")
        let ex2 = expectation(description: "")

        UIView.promise(animateWithDuration: 0.1) {
            ex1.fulfill()
        }.then { _ -> Void in
            ex2.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
