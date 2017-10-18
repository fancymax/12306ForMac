import PMKAlamofire
import OHHTTPStubs
import PromiseKit
import XCTest

class AlamofireTests: XCTestCase {
    func test() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }

        let ex = expectation(description: "")

        let rq = Alamofire.request("http://example.com", method: .get).responseJSON().then { rsp -> Void in
            XCTAssertEqual(json, rsp as? NSDictionary)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }
}
