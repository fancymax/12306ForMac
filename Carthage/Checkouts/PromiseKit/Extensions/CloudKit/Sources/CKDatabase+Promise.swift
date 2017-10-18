import CloudKit.CKDatabase
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `CKDatabase` category:

    use_frameworks!
    pod "PromiseKit/CloudKit"
 
 And then in your sources:

    @import PromiseKit;
*/
extension CKDatabase {
    /// Fetches one record asynchronously from the current database.
    public func fetch(withRecordID recordID: CKRecordID) -> Promise<CKRecord> {
        return PromiseKit.wrap { fetch(withRecordID: recordID, completionHandler: $0) }
    }

    /// Fetches one record zone asynchronously from the current database.
    public func fetch(withRecordZoneID recordZoneID: CKRecordZoneID) -> Promise<CKRecordZone> {
        return PromiseKit.wrap { fetch(withRecordZoneID: recordZoneID, completionHandler: $0) }
    }
    /// Fetches all record zones asynchronously from the current database.
    public func fetchAllRecordZones() -> Promise<[CKRecordZone]> {
        return PromiseKit.wrap { fetchAllRecordZones(completionHandler: $0) }
    }

    /// Saves one record zone asynchronously to the current database.
    public func save(_ record: CKRecord) -> Promise<CKRecord> {
        return PromiseKit.wrap { save(record, completionHandler: $0) }
    }

    /// Saves one record zone asynchronously to the current database.
    public func save(_ recordZone: CKRecordZone) -> Promise<CKRecordZone> {
        return PromiseKit.wrap { save(recordZone, completionHandler: $0) }
    }

    /// Delete one subscription object asynchronously from the current database.
    public func delete(withRecordID recordID: CKRecordID) -> Promise<CKRecordID> {
        return PromiseKit.wrap { delete(withRecordID: recordID, completionHandler: $0) }
    }

    /// Delete one subscription object asynchronously from the current database.
    public func delete(withRecordZoneID zoneID: CKRecordZoneID) -> Promise<CKRecordZoneID> {
        return PromiseKit.wrap { delete(withRecordZoneID: zoneID, completionHandler: $0) }
    }

    /// Searches the specified zone asynchronously for records that match the query parameters.
    public func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZoneID? = nil) -> Promise<[CKRecord]> {
        return PromiseKit.wrap { perform(query, inZoneWith: zoneID, completionHandler: $0) }
    }

    /// Fetches the record for the current user.
    public func fetchUserRecord(_ container: CKContainer = CKContainer.default()) -> Promise<CKRecord> {
        return container.fetchUserRecordID().then(on: zalgo) { uid -> Promise<CKRecord> in
            return self.fetch(withRecordID: uid)
        }
    }

#if !os(watchOS)
    /// Fetches one record zone asynchronously from the current database.
    public func fetch(withSubscriptionID subscriptionID: String) -> Promise<CKSubscription> {
        return PromiseKit.wrap { fetch(withSubscriptionID: subscriptionID, completionHandler: $0) }
    }

    /// Fetches all subscription objects asynchronously from the current database.
    public func fetchAllSubscriptions() -> Promise<[CKSubscription]> {
        return PromiseKit.wrap { fetchAllSubscriptions(completionHandler: $0) }
    }

    /// Saves one subscription object asynchronously to the current database.
    public func save(_ subscription: CKSubscription) -> Promise<CKSubscription> {
        return PromiseKit.wrap { save(subscription, completionHandler: $0) }
    }

    /// Delete one subscription object asynchronously from the current database.
    public func delete(withSubscriptionID subscriptionID: String) -> Promise<String> {
        return PromiseKit.wrap { delete(withSubscriptionID: subscriptionID, completionHandler: $0) }
    }
#endif
}
