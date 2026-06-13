#if canImport(CloudKit)
import CloudKit
import Foundation

@MainActor
public final class MemoryAtlasSyncCoordinator: ObservableObject {
    public static let containerIdentifier = "iCloud.org.worldclassscholars.memoryatlas"

    private let container: CKContainer
    private let database: CKDatabase
    private var pendingProfileExports: [PersonProfile] = []
    private var pendingArtifactExports: [MemoryArtifact] = []

    public init(containerIdentifier: String = MemoryAtlasSyncCoordinator.containerIdentifier) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.database = container.privateCloudDatabase
    }

    public func syncNow() async {
        // Boundary for CKSyncEngine integration. The v1 scaffold keeps this explicit so app code can compile
        // before a local persistence store is selected.
        await exportQueuedMirrors()
    }

    public func markProfileForSync(_ profile: PersonProfile) {
        pendingProfileExports.append(profile)
    }

    public func markArtifactForSync(_ artifact: MemoryArtifact) {
        pendingArtifactExports.append(artifact)
    }

    private func exportQueuedMirrors() async {
        let profiles = pendingProfileExports
        let artifacts = pendingArtifactExports
        pendingProfileExports.removeAll()
        pendingArtifactExports.removeAll()

        for profile in profiles {
            _ = try? await database.save(profile.cloudKitRecord)
        }
        for artifact in artifacts {
            _ = try? await database.save(artifact.cloudKitRecord)
        }
    }
}

private extension PersonProfile {
    var cloudKitRecord: CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: "CKPersonProfile", recordID: recordID)
        record["serverID"] = id.uuidString as CKRecordValue
        record["fullName"] = fullName as CKRecordValue
        record["preferredName"] = (preferredName ?? "") as CKRecordValue
        if let birthYear { record["birthYear"] = birthYear as CKRecordValue }
        record["preferredTopics"] = preferredTopics as CKRecordValue
        record["updatedAt"] = Date() as CKRecordValue
        return record
    }
}

private extension MemoryArtifact {
    var cloudKitRecord: CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: "CKMemoryArtifact", recordID: recordID)
        let profileRecordID = CKRecord.ID(recordName: profileID.uuidString)
        record["serverID"] = id.uuidString as CKRecordValue
        record["profileRef"] = CKRecord.Reference(recordID: profileRecordID, action: .none)
        record["title"] = title as CKRecordValue
        record["kind"] = kind.rawValue as CKRecordValue
        record["notes"] = notes as CKRecordValue
        record["tags"] = tags as CKRecordValue
        if let capturedAt { record["capturedAt"] = capturedAt as CKRecordValue }
        record["updatedAt"] = Date() as CKRecordValue
        return record
    }
}
#endif
