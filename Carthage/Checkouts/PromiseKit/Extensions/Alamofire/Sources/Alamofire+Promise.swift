@_exported import Alamofire
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `Alamofire` category:

     use_frameworks!
     pod "PromiseKit/Alamofire"

 And then in your sources:

     import PromiseKit
 */
extension Alamofire.DataRequest {
    /// Adds a handler to be called once the request has finished.
    public func response() -> Promise<(URLRequest, HTTPURLResponse, Data)> {
        return Promise { fulfill, reject in
            response(queue: nil) { rsp in
                if let error = rsp.error {
                    reject(error)
                } else if let a = rsp.request, let b = rsp.response, let c = rsp.data {
                    fulfill(a, b, c)
                } else {
                    reject(PMKError.invalidCallingConvention)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseData() -> Promise<Data> {
        return Promise { fulfill, reject in
            responseData(queue: nil) { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseString() -> Promise<String> {
        return Promise { fulfill, reject in
            responseString(queue: nil) { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> Promise<Any> {
        return Promise { fulfill, reject in
            responseJSON(queue: nil, options: options, completionHandler: { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            })
        }
    }

    /// Adds a handler to be called once the request has finished.
    public func responsePropertyList(options: PropertyListSerialization.ReadOptions = PropertyListSerialization.ReadOptions()) -> Promise<Any> {
        return Promise { fulfill, reject in
            responsePropertyList(queue: nil, options: options) { response in
                switch response.result {
                case .success(let value):
                    fulfill(value)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
}
