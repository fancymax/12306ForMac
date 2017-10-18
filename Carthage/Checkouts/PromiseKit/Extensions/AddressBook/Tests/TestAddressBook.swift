import PMKAddressBook
import AddressBook
import PromiseKit
import XCTest

class AddressBookTests: XCTestCase {
    func test() {
        let ex = expectation(description: "")
        ABAddressBookRequestAccess().then { (auth: ABAuthorizationStatus) in
            XCTAssertEqual(auth, ABAuthorizationStatus.authorized)
        }.then(execute: ex.fulfill)
        waitForExpectations(timeout: 1)
    }
}
