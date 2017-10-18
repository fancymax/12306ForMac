import PMKAccounts
import PromiseKit
import Accounts
import XCTest

class Test_ACAccountStore_Swift: XCTestCase {
    var dummy: ACAccount { return ACAccount() }

    func test_renewCredentialsForAccount() {
        let ex = expectation(description: "")

        class MockAccountStore: ACAccountStore {
            override func renewCredentials(for account: ACAccount!, completion: ACAccountStoreCredentialRenewalHandler!) {
                completion(.renewed, nil)
            }
        }

        MockAccountStore().renewCredentials(for: dummy).then { result -> Void in
            XCTAssertEqual(result, ACAccountCredentialRenewResult.renewed)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func test_requestAccessToAccountsWithType() {
        class MockAccountStore: ACAccountStore {
            override func requestAccessToAccounts(with accountType: ACAccountType!, options: [AnyHashable : Any]! = [:], completion: ACAccountStoreRequestAccessCompletionHandler!) {
                completion(true, nil)
            }
        }

        let ex = expectation(description: "")
        let store = MockAccountStore()
        let type = store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)!
        store.requestAccessToAccounts(with: type).then { _ in
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func test_saveAccount() {
        class MockAccountStore: ACAccountStore {
            override func saveAccount(_ account: ACAccount!, withCompletionHandler completionHandler: ACAccountStoreSaveCompletionHandler!) {
                completionHandler(true, nil)
            }
        }

        let ex = expectation(description: "")
        MockAccountStore().saveAccount(dummy).then { _ in
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func test_removeAccount() {
        class MockAccountStore: ACAccountStore {
            override func removeAccount(_ account: ACAccount!, withCompletionHandler completionHandler: ACAccountStoreSaveCompletionHandler!) {
                completionHandler(true, nil)
            }
        }

        let ex = expectation(description: "")
        MockAccountStore().removeAccount(dummy).then { _ in
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
