#if !COCOAPODS
@_exported import class PMKFoundation.URLDataPromise
import PromiseKit
#endif
import Social

/**
 To import the `SLRequest` category:

    use_frameworks!
    pod "PromiseKit/Social"

 And then in your sources:

    import PromiseKit
*/
extension SLRequest {
    /**
     Performs the request asynchronously.

     - Returns: A promise that fulfills with the response.
     - SeeAlso: `URLDataPromise`
    */
    public func perform() -> URLDataPromise {
        return URLDataPromise.go(preparedURLRequest(), body: perform)
    }
}
