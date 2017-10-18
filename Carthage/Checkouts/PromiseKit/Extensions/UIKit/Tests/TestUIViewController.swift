import PromiseKit
import PMKUIKit
import XCTest
import UIKit

private let dummy = 1_234_765


class UIViewControllerTests: XCTestCase {

    func test_rejects_if_vc_has_no_promise_property() {
        let ex = expectation(description: "")
        let p: Promise<Int> = rootvc.promise(UIViewController(), animate: [])
        p.catch { error in
            if case UIViewController.PMKError.notPromisable = error {
                ex.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_rejects_if_promise_property_returns_nil() {
        let ex = expectation(description: "")
        let p: Promise<Int> = rootvc.promise(MockViewController(), animate: [])
        p.catch { error in
            if case UIViewController.PMKError.nilPromisable = error {
                ex.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_rejects_if_promise_property_casts_wrongly() {
        let ex = expectation(description: "")
        let my = MockViewController()
        my.promise = Promise(value: true)
        let p: Promise<Int> = rootvc.promise(my, animate: [])
        p.catch { err in
            if case UIViewController.PMKError.notGenericallyPromisable = err {
                ex.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_resolved_promise_property_means_vc_does_not_appear() {
        let ex = expectation(description: "")
        let my = MockViewController()
        my.promise = Promise(value: dummy)
        rootvc.promise(my, animate: []).then { (x: Int) -> Void in
            XCTAssertFalse(my.appeared)
            XCTAssertEqual(x, dummy)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_vc_dismisses_once_promise_is_resolved() {
        let ex = expectation(description: "")
        let my = MockViewController()
        let (promise, resolve, _) = Promise<Int>.pending()
        my.promise = promise
        rootvc.promise(my, animate: []).then { (x: Int) -> Void in
            XCTAssertTrue(my.appeared)
            XCTAssertEqual(x, dummy)
            ex.fulfill()
        }
        after(interval: 0).then {
            resolve(dummy)
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_nav_controllers_use_their_root_vc_promise_property() {
        let ex = expectation(description: "")
        let nc = UINavigationController()
        let my = MockViewController()
        my.promise = after(interval: 0.1).then{ dummy }
        nc.viewControllers = [my]
        rootvc.promise(nc, animate: []).then { (x: Int) -> Void in
            XCTAssertTrue(my.appeared)
            XCTAssertEqual(x, dummy)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}



private class MockViewController: UIViewController, Promisable {
    @objc var promise: AnyObject! = nil

    var appeared = false

    private override func viewDidAppear(_ animated: Bool) {
        appeared = true
    }
}
