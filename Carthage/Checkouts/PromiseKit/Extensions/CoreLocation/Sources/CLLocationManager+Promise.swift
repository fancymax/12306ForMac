import CoreLocation.CLLocationManager
#if !COCOAPODS
import PromiseKit
#endif

#if !os(tvOS)

/**
 To import the `CLLocationManager` category:

    use_frameworks!
    pod "PromiseKit/CoreLocation"

 And then in your sources:

    import PromiseKit
*/
extension CLLocationManager {

    /// The location authorization type
    public enum RequestAuthorizationType {
        /// Determine the authorization from the application’s plist
        case automatic
        /// Request always-authorization
        case always
        /// Request when-in-use-authorization
        case whenInUse
    }

    fileprivate class func promiseDoneForLocationManager(_ manager: CLLocationManager) -> Void {
        manager.delegate = nil
        manager.stopUpdatingLocation()
    }
  
    /**
      - Returns: A new promise that fulfills with the most recent CLLocation.
      - Note: To return all locations call `allResults()`. 
      - Parameter requestAuthorizationType: We read your Info plist and try to
      determine the authorization type we should request automatically. If you
      want to force one or the other, change this parameter from its default
      value.
     */
    public class func promise(_ requestAuthorizationType: RequestAuthorizationType = .automatic) -> LocationPromise {
        return promise(yielding: auther(requestAuthorizationType))
    }

    private class func promise(yielding yield: (CLLocationManager) -> Void = { _ in }) -> LocationPromise {
        let manager = LocationManager()
        manager.delegate = manager
        yield(manager)
        manager.startUpdatingLocation()
        _ = manager.promise.always {
            CLLocationManager.promiseDoneForLocationManager(manager)
        }
        return manager.promise
    }
}

private class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    let (promise, fulfill, reject) = LocationPromise.foo()

    @objc fileprivate func locationManager(_ manager: CLLocationManager, didUpdateLocations ll: [CLLocation]) {
        let locations = ll 
        fulfill(locations)
        CLLocationManager.promiseDoneForLocationManager(manager)
    }

    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let error = error as NSError
        if error.code == CLError.locationUnknown.rawValue && error.domain == kCLErrorDomain {
            // Apple docs say you should just ignore this error
        } else {
            reject(error)
            CLLocationManager.promiseDoneForLocationManager(manager)
        }
    }
}


#if os(iOS)

extension CLLocationManager {
    /**
     Cannot error, despite the fact this might be more useful in some
     circumstances, we stick with our decision that errors are errors
     and errors only. Thus your catch handler is always catching failures
     and not being abused for logic.
    */
    @available(iOS 8, *)
    public class func requestAuthorization(type: RequestAuthorizationType = .automatic) -> Promise<CLAuthorizationStatus> {
        return AuthorizationCatcher(auther: auther(type)).promise
    }
}

@available(iOS 8, *)
private class AuthorizationCatcher: CLLocationManager, CLLocationManagerDelegate {
    let (promise, fulfill, _) = Promise<CLAuthorizationStatus>.pending()
    var retainCycle: AnyObject?

    init(auther: (CLLocationManager)->()) {
        super.init()
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            delegate = self
            auther(self)
            retainCycle = self
        } else {
            fulfill(status)
        }
    }

    @objc fileprivate func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            fulfill(status)
            retainCycle = nil
        }
    }
}

private func auther(_ requestAuthorizationType: CLLocationManager.RequestAuthorizationType) -> ((CLLocationManager) -> Void) {

    //PMKiOS7 guard #available(iOS 8, *) else { return }
    return { manager in
        func hasInfoPlistKey(_ key: String) -> Bool {
            let value = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
            return !value.isEmpty
        }

        switch requestAuthorizationType {
        case .automatic:
            let always = hasInfoPlistKey("NSLocationAlwaysUsageDescription")
            let whenInUse = hasInfoPlistKey("NSLocationWhenInUseUsageDescription")
            if always {
                manager.requestAlwaysAuthorization()
            } else {
                if !whenInUse { NSLog("PromiseKit: Warning: `NSLocationWhenInUseUsageDescription` key not set") }
                manager.requestWhenInUseAuthorization()
            }
        case .whenInUse:
            manager.requestWhenInUseAuthorization()
            break
        case .always:
            manager.requestAlwaysAuthorization()
            break

        }
    }
}

#else

private func auther(_ requestAuthorizationType: CLLocationManager.RequestAuthorizationType) -> (CLLocationManager) -> Void {
    return { _ in }
}

#endif


/// The promise returned by CLLocationManager.promise()
public class LocationPromise: Promise<CLLocation> {
    // convoluted for concurrency guarantees
    private let (parentPromise, fulfill, reject) = Promise<[CLLocation]>.pending()

    /// Convert the promise so that all Location results are returned
    public func asArray() -> Promise<[CLLocation]> {
        return parentPromise
    }

    fileprivate class func foo() -> (LocationPromise, ([CLLocation]) -> Void, (Error) -> Void) {
        var fulfill: ((CLLocation) -> Void)!
        var reject: ((Error) -> Void)!
        let promise = LocationPromise { fulfill = $0; reject = $1 }

        _ = promise.parentPromise.then(on: zalgo) { fulfill($0.last!) }
        promise.parentPromise.catch(on: zalgo, execute: reject)

        return (promise, promise.fulfill, promise.reject)
    }
}

#endif
