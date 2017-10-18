import PMKCloudKit

import XCTest

//TODO possibly we should interpret eg. request permission result of Denied as error
// PMK should only resolve with values that allow a typical chain to proceed

class Test_CKContainer_Swift: XCTestCase {

    func test_accountStatus() {
        class MockContainer: CKContainer {
            init(_: Bool = false)
            {}

            private override func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
                completionHandler(.couldNotDetermine, nil)
            }
        }

        let ex = expectation(description: "")
        MockContainer().accountStatus().then { status -> Void in
            XCTAssertEqual(status, CKAccountStatus.couldNotDetermine)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_requestApplicationPermission() {
        class MockContainer: CKContainer {
            init(_: Bool = false)
            {}

            private override func requestApplicationPermission(_ applicationPermission: CKApplicationPermissions, completionHandler: @escaping CKApplicationPermissionBlock) {
                completionHandler(.granted, nil)
            }
        }

        let ex = expectation(description: "")
        let pp = CKApplicationPermissions.userDiscoverability
        MockContainer().requestApplicationPermission(pp).then { perms -> Void in
            XCTAssertEqual(perms, CKApplicationPermissionStatus.granted)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_statusForApplicationPermission() {
        class MockContainer: CKContainer {
            init(_: Bool = false)
            {}

            private override func status(forApplicationPermission applicationPermission: CKApplicationPermissions, completionHandler: @escaping CKApplicationPermissionBlock) {
                completionHandler(.granted, nil)
            }
        }

        let ex = expectation(description: "")
        let pp = CKApplicationPermissions.userDiscoverability
        MockContainer().status(forApplicationPermission: pp).then {
            XCTAssertEqual($0, CKApplicationPermissionStatus.granted)
        }.then(execute: ex.fulfill)
        waitForExpectations(timeout: 1, handler: nil)
    }

#if !os(tvOS)
    func test_discoverAllContactUserInfos() {
        class MockContainer: CKContainer {
            init(_: Bool = false)
            {}

            private override func discoverAllContactUserInfos(completionHandler: @escaping ([CKDiscoveredUserInfo]?, Error?) -> Void) {
                completionHandler([PMKDiscoveredUserInfo()], nil)
            }
        }

        let ex = expectation(description: "")
        MockContainer().discoverAllContactUserInfos().then {
            XCTAssertEqual($0, [PMKDiscoveredUserInfo()])
        }.then(execute: ex.fulfill)
        waitForExpectations(timeout: 1, handler: nil)
    }
#endif

    func test_discoverUserInfoWithEmailAddress() {
        class MockContainer: CKContainer {
            init(_: Bool = false)
            {}

            private override func discoverUserInfo(withEmailAddress email: String, completionHandler: @escaping (CKDiscoveredUserInfo?, Error?) -> Void) {
                completionHandler(PMKDiscoveredUserInfo(), nil)
            }
        }

        let ex = expectation(description: "")
        MockContainer().discoverUserInfo(withEmailAddress: "mxcl@me.com").then {
            XCTAssertEqual($0, PMKDiscoveredUserInfo())
        }.then(execute: ex.fulfill)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_discoverUserInfoWithRecordID() {
        class MockContainer: CKContainer {
            init(_: Bool = false)
            {}

            private override func discoverUserInfo(withUserRecordID userRecordID: CKRecordID, completionHandler: @escaping (CKDiscoveredUserInfo?, Error?) -> Void) {
                completionHandler(PMKDiscoveredUserInfo(), nil)
            }
        }

        let ex = expectation(description: "")
        MockContainer().discoverUserInfo(withUserRecordID: dummy()).then {
            XCTAssertEqual($0, PMKDiscoveredUserInfo())
        }.then(execute: ex.fulfill)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_fetchUserRecordID() {
        class MockContainer: CKContainer {
            init(_: Bool = false)
            {}

            private override func fetchUserRecordID(completionHandler: @escaping (CKRecordID?, Error?) -> Void) {
                completionHandler(dummy(), nil)
            }
        }

        let ex = expectation(description: "")
        MockContainer().fetchUserRecordID().then {
            XCTAssertEqual($0, dummy())
        }.then(execute: ex.fulfill)
        waitForExpectations(timeout: 1, handler: nil)
    }
}



/////////////////////////////////////////////////////////////// resources

private func dummy() -> CKRecordID {
    return CKRecordID(recordName: "foo")
}
