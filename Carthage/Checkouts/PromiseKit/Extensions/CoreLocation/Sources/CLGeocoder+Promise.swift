import CoreLocation.CLGeocoder
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `CLGeocoder` category:

    use_frameworks!
    pod "PromiseKit/CoreLocation"

 And then in your sources:

    import PromiseKit
*/
extension CLGeocoder {
    /// Submits a reverse-geocoding request for the specified location.
    public func reverseGeocode(location: CLLocation) -> PlacemarkPromise {
        return PlacemarkPromise.go { resolve in
            reverseGeocodeLocation(location, completionHandler: resolve)
        }
    }

    /// Submits a forward-geocoding request using the specified address dictionary.
    public func geocode(_ addressDictionary: [String: String]) -> PlacemarkPromise {
        return PlacemarkPromise.go { resolve in
            geocodeAddressDictionary(addressDictionary, completionHandler: resolve)
        }
    }

    /// Submits a forward-geocoding request using the specified address string.
    public func geocode(_ addressString: String) -> PlacemarkPromise {
        return PlacemarkPromise.go { resolve in
            geocodeAddressString(addressString, completionHandler: resolve)
        }
    }

    /// Submits a forward-geocoding request using the specified address string within the specified region.
    public func geocode(_ addressString: String, region: CLRegion?) -> PlacemarkPromise {
        return PlacemarkPromise.go { resolve in
            geocodeAddressString(addressString, in: region, completionHandler: resolve)
        }
    }
}

// Xcode 8 beta 6 doesn't import CLError as Swift.Error
//extension CLError: CancellableError {
//    public var isCancelled: Bool {
//        return self == .geocodeCanceled
//    }
//}

/// A promise that returns the first CLPlacemark from an array of results.
public class PlacemarkPromise: Promise<CLPlacemark> {

    /// Returns all CLPlacemarks rather than just the first
    public func asArray() -> Promise<[CLPlacemark]> {
        return then(on: zalgo) { _ in return self.placemarks }
    }

    private var placemarks: [CLPlacemark]!

    fileprivate class func go(_ body: (@escaping ([CLPlacemark]?, Error?) -> Void) -> Void) -> PlacemarkPromise {
        var promise: PlacemarkPromise!
        promise = PlacemarkPromise { fulfill, reject in
            body { placemarks, error in
                if let error = error {
                    reject(error)
                } else {
                    promise.placemarks = placemarks
                    fulfill(placemarks!.first!)
                }
            }
        }
        return promise
    }
}
