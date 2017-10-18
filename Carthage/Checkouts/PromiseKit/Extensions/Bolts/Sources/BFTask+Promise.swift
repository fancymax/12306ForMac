import Bolts

extension Promise {
    /**
     The provided closure is executed when this promise is resolved.
     */
    public func then<U: AnyObject>(on q: DispatchQueue = .default, body: @escaping (T) -> BFTask<U>) -> Promise<U?> {
        return then(on: q) { tee -> Promise<U?> in
            let task = body(tee)
            return Promise<U?> { fulfill, reject in
                task.continue({ task in
                    if task.isCompleted {
                        fulfill(task.result)
                    } else {
                        reject(task.error!)
                    }
                    return nil
                })
            }
        }
    }
}

//FIXME won’t compile with Xcode 8 beta 4
//extension BFTask {
//    public func then<U>(on q: DispatchQueue = PMKDefaultDispatchQueue(), body: (ResultType) -> U) -> Promise<U> {
//        return Promise { fulfill, reject in
//            self.continue({ task in
//                if task.isCompleted {
//                    q.async {  //FIXME zalgo
//                        fulfill(body(task.result))
//                    }
//                } else {
//                    reject(task.error!)
//                }
//                return nil
//            })
//        }
//    }
//}

#if !COCOAPODS
import PromiseKit
#endif
