import UIKit
#if !COCOAPODS
import PromiseKit
#endif

#if !os(tvOS)

extension UIViewController {
    @available(*, deprecated: 3.4, renamed: "promise(_:animate:fulfills:completion:)")
    public func promiseViewController(_ vc: UIImagePickerController, animated: Bool = true, completion: (() -> Void)? = nil) -> Promise<UIImage> {
        return promise(vc, animate: animated ? [.appear, .disappear] : [], completion: completion)
    }

    @available(*, deprecated: 3.4, renamed: "promise(_:animate:fulfills:completion:)")
    public func promiseViewController(_ vc: UIImagePickerController, animated: Bool = true, completion: (() -> Void)? = nil) -> Promise<[String: AnyObject]> {
        return promise(vc, animate: animated ? [.appear, .disappear] : [], completion: completion)
    }

    /// Presents the UIImagePickerController, resolving with the user action.
    public func promise(_ vc: UIImagePickerController, animate: PMKAnimationOptions = [.appear, .disappear], completion: (() -> Void)? = nil) -> Promise<UIImage> {
        let animated = animate.contains(.appear)
        let proxy = UIImagePickerControllerProxy()
        vc.delegate = proxy
        vc.mediaTypes = ["public.image"]  // this promise can only resolve with a UIImage
        present(vc, animated: animated, completion: completion)
        return proxy.promise.then(on: zalgo) { info -> UIImage in
            if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
                return img
            }
            if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
                return img
            }
            throw PMKError.noImageFound
        }.always {
            vc.presentingViewController?.dismiss(animated: animated, completion: nil)
        }
    }

    /// Presents the UIImagePickerController, resolving with the user action.
    public func promise(_ vc: UIImagePickerController, animate: PMKAnimationOptions = [.appear, .disappear], completion: (() -> Void)? = nil) -> Promise<[String: Any]> {
        let animated = animate.contains(.appear)
        let proxy = UIImagePickerControllerProxy()
        vc.delegate = proxy
        present(vc, animated: animated, completion: completion)
        return proxy.promise.always {
            vc.presentingViewController?.dismiss(animated: animated, completion: nil)
        }
    }
}

@objc private class UIImagePickerControllerProxy: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let (promise, fulfill, reject) = Promise<[String : Any]>.pending()
    var retainCycle: AnyObject?

    required override init() {
        super.init()
        retainCycle = self
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        fulfill(info)
        retainCycle = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        reject(UIImagePickerController.PMKError.cancelled)
        retainCycle = nil
    }
}

extension UIImagePickerController {
    /// Errors representing PromiseKit UIImagePickerController failures
    public enum PMKError: CancellableError {
        /// The user cancelled the UIImagePickerController.
        case cancelled
        /// - Returns: true
        public var isCancelled: Bool {
            switch self {
            case .cancelled:
                return true
            }
        }
    }
}

#endif
