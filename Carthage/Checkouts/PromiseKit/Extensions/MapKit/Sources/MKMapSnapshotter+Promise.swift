import MapKit
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `MKMapSnapshotter` category:

    use_frameworks!
    pod "PromiseKit/MapKit"

 And then in your sources:

    import PromiseKit
*/
extension MKMapSnapshotter {
    /// Starts generating the snapshot using the options set in this object.
    public func start() -> Promise<MKMapSnapshot> {
        return PromiseKit.wrap(start)
    }
}
