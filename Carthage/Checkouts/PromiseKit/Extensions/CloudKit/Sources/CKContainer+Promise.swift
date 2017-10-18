import CloudKit
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `CKContainer` category:

    use_frameworks!
    pod "PromiseKit/CloudKit"
 
 And then in your sources:

    @import PromiseKit;
*/
extension CKContainer {
    /// Reports whether the current user’s iCloud account can be accessed.
    public func accountStatus() -> Promise<CKAccountStatus> {
        return PromiseKit.wrap(accountStatus)
    }

    /// Requests the specified permission from the user asynchronously.
    public func requestApplicationPermission(_ applicationPermissions: CKApplicationPermissions) -> Promise<CKApplicationPermissionStatus> {
        return PromiseKit.wrap { requestApplicationPermission(applicationPermissions, completionHandler: $0) }
    }

    /// Checks the status of the specified permission asynchronously.
    public func status(forApplicationPermission applicationPermissions: CKApplicationPermissions) -> Promise<CKApplicationPermissionStatus> {
        return PromiseKit.wrap { status(forApplicationPermission: applicationPermissions, completionHandler: $0) }
    }

#if !os(tvOS)
    /// Retrieves information about all discoverable users that are known to the current user.
    public func discoverAllContactUserInfos() -> Promise<[CKDiscoveredUserInfo]> {
        return PromiseKit.wrap(discoverAllContactUserInfos)
    }
#endif

    /// Retrieves information about a single user based on that user’s email address.
    public func discoverUserInfo(withEmailAddress email: String) -> Promise<CKDiscoveredUserInfo> {
        return PromiseKit.wrap { discoverUserInfo(withEmailAddress: email, completionHandler: $0) }
    }

    /// Retrieves information about a single user based on the ID of the corresponding user record.
    public func discoverUserInfo(withUserRecordID recordID: CKRecordID) -> Promise<CKDiscoveredUserInfo> {
        return PromiseKit.wrap { self.discoverUserInfo(withUserRecordID: recordID, completionHandler: $0) }
    }

    /// Returns the user record ID associated with the current user.
    public func fetchUserRecordID() -> Promise<CKRecordID> {
        return PromiseKit.wrap(fetchUserRecordID)
    }
}
