import PMKCoreLocation
import CoreLocation
import PromiseKit
import XCTest

class CLGeocoderTests: XCTestCase {
    func test_reverseGeocodeLocation() {
        class MockGeocoder: CLGeocoder {
            private override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(interval: 0).then {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        MockGeocoder().reverseGeocode(location: CLLocation()).then { x -> Void in
            XCTAssertEqual(x, dummyPlacemark)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_geocodeAddressDictionary() {
        class MockGeocoder: CLGeocoder {

            private override func geocodeAddressDictionary(_ addressDictionary: [AnyHashable : Any], completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(interval: 0.0).then {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        MockGeocoder().geocode([:]).then { x -> Void in
            XCTAssertEqual(x, dummyPlacemark)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test_geocodeAddressString() {
        class MockGeocoder: CLGeocoder {
            override func geocodeAddressString(_ addressString: String, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(interval: 0.0).then {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        MockGeocoder().geocode("").then { x -> Void in
            XCTAssertEqual(x, dummyPlacemark)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}

private let dummyPlacemark = CLPlacemark()
