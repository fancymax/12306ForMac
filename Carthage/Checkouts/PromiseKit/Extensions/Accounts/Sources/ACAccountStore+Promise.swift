import Accounts
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `ACAccountStore` category:

    use_frameworks!
    pod "PromiseKit/ACAccountStore"

 And then in your sources:

    import PromiseKit
*/
extension ACAccountStore {
    /// Renews account credentials when the credentials are no longer valid.
    public func renewCredentials(for account: ACAccount) -> Promise<ACAccountCredentialRenewResult> {
        return PromiseKit.wrap { renewCredentials(for: account, completion: $0) }
    }

    /// Obtains permission to access protected user properties.
    public func requestAccessToAccounts(with type: ACAccountType, options: [AnyHashable: Any]? = nil) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            requestAccessToAccounts(with: type, options: options, completion: { granted, error in
                if granted {
                    fulfill()
                } else if let error = error {
                    reject(error)
                } else {
                    reject(PMKError.accessDenied)
                }
            })
        }
    }

    /// Saves an account to the Accounts database.
    public func saveAccount(_ account: ACAccount) -> Promise<Void> {
        return PromiseKit.wrap { saveAccount(account, withCompletionHandler: $0) }.asVoid()
    }

    /// Removes an account from the account store.
    public func removeAccount(_ account: ACAccount) -> Promise<Void> {
        return PromiseKit.wrap { removeAccount(account, withCompletionHandler: $0) }.asVoid()
    }

    /// PromiseKit ACAccountStore errors
    public enum PMKError: Error, CustomStringConvertible {
        /// The request for accounts access was denied.
        case accessDenied

        public var description: String {
            switch self {
            case .accessDenied:
                return "Access to the requested social service has been denied. Please enable access in your device settings."
            }
        }
    }
}
