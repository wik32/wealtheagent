# ADR-002: CloudKit Data Model

**Status:** Accepted  
**Date:** 2026-06-26  
**Deciders:** Fabian Benusch (sole developer)  
**Context:** FinanzApp SwiftUI rewrite — persistence layer  
**Supersedes:** Draft placeholder (same file)

---

## Context

FinanzApp requires persistent, private, per-user storage of financial contracts. The stack decision (CLAUDE.md, 2026-06-19) mandates CloudKit with iCloud Private Database. This ADR specifies the exact CKRecord schema, zone topology, field encoding strategy, index requirements, and the PendingContract lifecycle.

**CloudKit fundamentals constraining this design:**
- `CKRecord` is a schemaless key-value store. Schema is inferred on first save. Field types are fixed on first write — changing a field type requires a new field name.
- Supported scalar types: `String`, `Int64`, `Double`, `Date`, `Data`, `CKAsset`, `CLLocation`, `[String]`, `[Int64]`, `[Double]`, `[Date]`, `[Data]`, `CKRecord.Reference`.
- No native nested object support. No `[Dictionary]`. Semi-structured data requires a JSON string or multiple records.
- `CKRecordZone` default zone: no delta-sync token. Custom zone: supports `CKFetchRecordZoneChangesOperation` with a `serverChangeToken` — fetches only records changed since the last sync.
- `CKSubscription` (database subscription): push notifications via APNs when records in a zone change.
- Record size limit: 1 MB per CKRecord. CKAsset: for blobs > ~100 KB.
- CloudKit private database: zero cost up to iCloud storage quota. EU data residency via Apple DPA.

**Capacity estimation (informs field encoding choice):**
- Portfolio size: 10–30 contracts per user (order of magnitude).
- `fieldsJSON` per contract: largest category has ~8 fields × ~60 bytes each = ~480 bytes. Rounded up to 1 KB including encoding overhead.
- `criteriaJSON` per contract: up to 8 criteria × ~30 bytes = ~240 bytes.
- `rawOCRText` in PendingContract: typical German insurance document = ~3 KB text, worst-case full policy = ~20 KB. Well under 1 MB limit. String encoding (not CKAsset) is sufficient.
- Total per Contract record: ~2 KB. Total per user at 30 contracts: ~60 KB. Sync payload per launch (delta): typically 0–5 changed records. CloudKit has no bandwidth cost concern at this scale.

**Domain types to persist:**
1. `Contract` — confirmed contract.
2. `PendingContract` — OCR output awaiting user review. Stored in CloudKit (Decision D2, 2026-06-26).
3. `UserProfile` — onboarding answers and preferences.

---

## Decision

### Zone

**Zone name:** `FinanzAppZone`  
**Database:** Private Database  
**Owner:** Current iCloud account (automatic)  
**Created by:** `CloudKitContractRepository.probe()` at app startup via `CKModifyRecordZonesOperation`.

All three record types (`Contract`, `PendingContract`, `UserProfile`) live in `FinanzAppZone`. A single custom zone is sufficient — no partitioning needed at this data volume.

**Why custom zone over default zone:**
- `CKFetchRecordZoneChangesOperation` on a custom zone returns only records changed since a saved `serverChangeToken`. The default zone does not support server change tokens, forcing a full re-fetch on every launch.
- Atomic batches: `CKModifyRecordsOperation` on a custom zone is atomic — all records in a batch save or all fail.

**Zone creation (in `probe()`):**
```swift
// probe() creates zone if absent — idempotent
let zone = CKRecordZone(zoneName: "FinanzAppZone")
let op = CKModifyRecordZonesOperation(recordZonesToSave: [zone],
                                       recordZoneIDsToDelete: nil)
op.modifyRecordZonesResultBlock = { result in
    switch result {
    case .success: // zone ready
    case .failure(let error): // probe fails → refuse startup
    }
}
CKContainer.default().privateCloudDatabase.add(op)
```

---

### Record Type: `Contract`

**CKRecord type key:** `"Contract"`  
**Zone:** `FinanzAppZone`  
**Represents:** A user-confirmed financial contract.

#### Field Schema

| CK Field Name | CK Type | Nullable | Swift Property | Notes |
|---|---|---|---|---|
| `categoryKey` | `String` | No | `contract.categoryKey` | Matches `catalog.json` key. E.g. `"privathaftpflicht"`, `"depot"`. Queryable — see Indexes. |
| `provider` | `String` | No | `contract.provider` | Insurer or institution name. Required on confirmation. |
| `contractNumber` | `String` | Yes | `contract.contractNumber` | Policy or account number. Nil if not extracted. |
| `startDate` | `Date` | Yes | `contract.startDate` | Contract start / policy inception date. |
| `endDate` | `Date` | Yes | `contract.endDate` | Contract end date. Nil for open-ended contracts. |
| `premiumAmount` | `Double` | Yes | `contract.premiumAmount` | Gross premium in EUR. Promoted to top level for client-side aggregation without JSON parse. |
| `premiumInterval` | `String` | Yes | `contract.premiumInterval` | One of: `"monatlich"`, `"vierteljaehrlich"`, `"halbjaehrlich"`, `"jaehrlich"`, `"einmalig"`. |
| `fieldsJSON` | `String` | No | `contract.fields` | Full field map as JSON string. Handles all category-specific fields. See encoding note. |
| `criteriaJSON` | `String` | Yes | `contract.criteria` | Criterion key → `Bool` map as JSON string. Nil for categories with no criteria. |
| `schemaVersion` | `String` | No | constant `"1.0"` | Bumped when `fieldsJSON` structure changes. Enables migration in `ContractMigrator`. |

**System fields (set automatically by CloudKit, no explicit mapping needed):**
- `creationDate` → `CKRecord.creationDate` (read-only, maps to `contract.createdAt`)
- `modificationDate` → `CKRecord.modificationDate` (read-only, maps to `contract.modifiedAt`)
- `recordID.recordName` → maps to `contract.id` (UUID string, set by the app on record creation)

#### Record ID Strategy

```swift
// App-generated UUID as recordName — stable across saves
let recordID = CKRecord.ID(
    recordName: contract.id.uuidString,  // UUID v4
    zoneID: CKRecordZone.ID(zoneName: "FinanzAppZone")
)
let record = CKRecord(recordType: "Contract", recordID: recordID)
```

Using the domain model's UUID as the CloudKit `recordName` means:
- Upsert is a plain `CKModifyRecordsOperation` — no separate lookup needed.
- Local cache keyed by `UUID` maps 1:1 to CloudKit `recordName`.
- No risk of duplicate records on retry (save is idempotent by `recordName`).

#### `fieldsJSON` Encoding

The `fields` property on `Contract` is a `[String: ContractFieldValue]` dictionary where `ContractFieldValue` is an enum covering `String`, `Double`, `Date`, `Bool`, `[String]`. Encode as JSON:

```swift
// Encoding (Contract -> CKRecord)
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
record["fieldsJSON"] = try String(
    data: encoder.encode(contract.fields),
    encoding: .utf8
)

// Decoding (CKRecord -> Contract)
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
guard let json = record["fieldsJSON"] as? String,
      let data = json.data(using: .utf8) else {
    throw CKMappingError.missingRequiredField("fieldsJSON")
}
let fields = try decoder.decode([String: ContractFieldValue].self, from: data)
```

**Why String (JSON) not `Data` (NSData):** CKRecord `Data` fields behave identically to `String` for blobs under 1 MB but lose readability in the CloudKit Dashboard. `String` fields are displayable in the dashboard, aiding debugging. For Stage 1, readability wins. Migrate to `Data` only if JSON size becomes a concern (it will not at this scale).

**Why not CKAsset:** CKAsset is designed for large binary blobs (images, audio). It incurs an additional network round-trip (separate upload/download outside the record). At ~1 KB per `fieldsJSON`, using CKAsset would add latency with zero benefit.

---

### Record Type: `PendingContract`

**CKRecord type key:** `"PendingContract"`  
**Zone:** `FinanzAppZone`  
**Represents:** An OCR extraction result awaiting user review. Created when `VisionDocumentScanner` completes; deleted when the user confirms (promoting to `Contract`) or discards.

#### Field Schema

| CK Field Name | CK Type | Nullable | Swift Property | Notes |
|---|---|---|---|---|
| `categoryKey` | `String` | Yes | `pending.categoryKey` | Nil if OCR could not determine category. User sets during review. |
| `provider` | `String` | Yes | `pending.provider` | Extracted provider name. Nil if not found. |
| `contractNumber` | `String` | Yes | `pending.contractNumber` | Extracted policy number. |
| `startDate` | `Date` | Yes | `pending.startDate` | Extracted start date. |
| `premiumAmount` | `Double` | Yes | `pending.premiumAmount` | Extracted premium amount. |
| `premiumInterval` | `String` | Yes | `pending.premiumInterval` | Extracted interval. |
| `fieldsJSON` | `String` | Yes | `pending.fields` | Partially-populated field map. Same encoding as `Contract.fieldsJSON`. Nil if extraction produced no structured fields. |
| `rawOCRText` | `String` | No | `pending.rawOCRText` | Full raw text from VNRecognizeTextRequest. Max ~20 KB. Stored as String (not CKAsset). Enables re-parsing if `ContractParser` heuristics improve. |
| `ocrConfidence` | `Double` | No | `pending.ocrConfidence` | Mean confidence across all VNRecognizedTextObservation blocks. Range 0.0–1.0. |
| `extractedAt` | `Date` | No | `pending.extractedAt` | Timestamp of VNRecognizeTextRequest completion. |
| `schemaVersion` | `String` | No | constant `"1.0"` | Same migration path as `Contract`. |

**Fields intentionally omitted from `PendingContract`:** `criteriaJSON` — criteria comparison is only meaningful for confirmed contracts where the category is known and fields are complete.

#### PendingContract Lifecycle in CloudKit

The lifecycle follows a **delete-and-create** pattern (not update-in-place):

```
1. OCR completes (VisionDocumentScanner)
       ↓
2. ContractParser.parseFields(ocr:category:) -> ContractFields (may be partial)
       ↓
3. CloudKitContractRepository.savePending(_:)
   → CKRecord(recordType: "PendingContract", recordID: <uuid>)
   → CKModifyRecordsOperation(.save)
       ↓
4. ReviewViewModel presents PendingContract to user
       ↓
   User confirms + optionally corrects fields
       ↓
5. CloudKitContractRepository.confirm(pending:corrected:)
   → Step A: CKModifyRecordsOperation(.delete pendingRecord)
   → Step B: CKRecord(recordType: "Contract", ...) with confirmed/corrected fields
   → CKModifyRecordsOperation(.save contractRecord)
   Both operations submitted in a single CKModifyRecordsOperation batch
   (atomicity: either both succeed or neither persists)
       ↓
6. On success: remove PendingContract from local cache, add Contract to local cache
       ↓
   User discards (alternative path at step 4):
       ↓
5b. CloudKitContractRepository.discard(pending:)
    → CKModifyRecordsOperation(.delete pendingRecord)
```

**Why delete-and-create, not update-in-place:**
- `PendingContract` and `Contract` are different record types with different field schemas. CloudKit does not support changing a record's type.
- A `PendingContract` record updated with all `Contract` fields would retain the `rawOCRText` field permanently, wasting storage and creating a semantic lie (a "confirmed" record that contains OCR review state).
- The combined delete+save in one `CKModifyRecordsOperation` is atomic in a custom zone — no orphan states possible.

**Orphan cleanup:**
PendingContracts older than 30 days are deleted on app launch. `CloudKitContractRepository.cleanupStalePending()` runs after the initial `listPendingContracts()` fetch:

```swift
func cleanupStalePending() async throws {
    let cutoff = Date().addingTimeInterval(-30 * 24 * 3600)
    let stale = pendingContracts.filter { $0.extractedAt < cutoff }
    guard !stale.isEmpty else { return }
    let ids = stale.map { CKRecord.ID(recordName: $0.id.uuidString, zoneID: zoneID) }
    let op = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: ids)
    op.savePolicy = .changedKeys
    // ... submit and handle result
}
```

Rationale for 30-day TTL: a PendingContract that the user has not reviewed in 30 days is almost certainly abandoned (user photographed wrong document, OCR failed, user forgot). Silent deletion after 30 days is preferable to accumulating orphans. The ReviewView shows a "pending since X days ago" label so users are aware.

---

### Record Type: `UserProfile`

**CKRecord type key:** `"UserProfile"`  
**Zone:** `FinanzAppZone`  
**Represents:** Onboarding answers and app preferences. At most one per iCloud account.

#### Field Schema

| CK Field Name | CK Type | Nullable | Notes |
|---|---|---|---|
| `onboardingComplete` | `Int64` | No | `1` = onboarding finished. Checked on every launch to gate TabView vs OnboardingView. |
| `languagePreference` | `String` | Yes | `"de"` or `"en"`. Overrides system locale if set. Nil = follow system. |
| `householdSize` | `Int64` | Yes | From onboarding step 1. |
| `hasPartner` | `Int64` | Yes | `0` or `1`. CloudKit has no native Bool — use Int64. |
| `hasChildren` | `Int64` | Yes | `0` or `1`. |
| `schemaVersion` | `String` | No | `"1.0"` |

**Record ID:** Fixed `recordName: "userprofile"` (lowercase, no UUID). There is exactly one `UserProfile` per iCloud account. A fixed name enables upsert semantics — no query needed to find the profile record.

```swift
let profileID = CKRecord.ID(recordName: "userprofile", zoneID: zoneID)
```

**Onboarding gate logic:** On launch, `CloudKitContractRepository.fetchUserProfile()` attempts to load this record. If it returns `CKError.unknownItem` (record does not exist) or `onboardingComplete == 0`, the app presents `OnboardingView`. If the fetch fails due to network error, the app falls back to `UserDefaults.onboardingComplete` (cached locally after onboarding).

---

### Indexes (CloudKit Dashboard Configuration)

CloudKit Dashboard allows marking fields as queryable. Fields that are not marked queryable cannot be used in `NSPredicate` on `CKQueryOperation`. For this app, server-side queries are minimal (client-side aggregation is acceptable at 10–30 records), but these fields need indexes to support future queries and dashboard exploration:

| Record Type | Field | Index Type | Justification |
|---|---|---|---|
| `Contract` | `categoryKey` | Queryable | Group/filter by contract type client-side and potentially server-side. |
| `Contract` | `premiumAmount` | Sortable | Sort by premium for future "most expensive" aggregate view. |
| `Contract` | `modificationDate` | Sortable | `CKFetchRecordZoneChangesOperation` uses this implicitly for delta sync ordering. |
| `PendingContract` | `extractedAt` | Sortable | Sort pending reviews by age; orphan cleanup comparison. |
| `PendingContract` | `categoryKey` | Queryable | Optional: filter pending by category in ReviewView. |
| `UserProfile` | `onboardingComplete` | Queryable | Direct lookup. (Effectively moot given fixed recordName, but useful for dashboard queries.) |

**Note on `CKFetchRecordZoneChangesOperation`:** This operation does not require explicit indexes — it uses the server change token to return a diff, not a predicate query. The indexes above are for explicit `CKQueryOperation` use cases only.

**Default zone behavior:** CloudKit creates a `SELF` index automatically on `recordID`. All other indexes must be added in the CloudKit Dashboard under "Indexes" for the relevant record type and database (Private). Index creation on an existing record type does not require app code changes.

---

## CKRecord Mapping Code Contracts

The crafter must implement the following extensions in `CloudKitContractRepository.swift`:

```swift
// MARK: - Contract <-> CKRecord

extension CKRecord {
    convenience init(contract: Contract, zoneID: CKRecordZone.ID) throws {
        let id = CKRecord.ID(recordName: contract.id.uuidString, zoneID: zoneID)
        self.init(recordType: "Contract", recordID: id)
        self["categoryKey"]      = contract.categoryKey
        self["provider"]         = contract.provider
        self["contractNumber"]   = contract.contractNumber
        self["startDate"]        = contract.startDate
        self["endDate"]          = contract.endDate
        self["premiumAmount"]    = contract.premiumAmount as? Double
        self["premiumInterval"]  = contract.premiumInterval
        self["fieldsJSON"]       = try contract.fields.encodeToJSONString()
        self["criteriaJSON"]     = try contract.criteria?.encodeToJSONString()
        self["schemaVersion"]    = "1.0"
    }
}

extension Contract {
    init(record: CKRecord) throws {
        guard let categoryKey = record["categoryKey"] as? String,
              let provider    = record["provider"]    as? String,
              let fieldsJSON  = record["fieldsJSON"]  as? String,
              let idString    = record.recordID.recordName as String?,
              let id          = UUID(uuidString: idString)
        else { throw CKMappingError.missingRequiredField("categoryKey/provider/fieldsJSON/id") }

        self.id              = id
        self.categoryKey     = categoryKey
        self.provider        = provider
        self.contractNumber  = record["contractNumber"] as? String
        self.startDate       = record["startDate"]      as? Date
        self.endDate         = record["endDate"]        as? Date
        self.premiumAmount   = record["premiumAmount"]  as? Double
        self.premiumInterval = record["premiumInterval"] as? String
        self.fields          = try ContractFields.decodeFromJSONString(fieldsJSON)
        self.criteria        = try (record["criteriaJSON"] as? String)
                                    .map { try ContractCriteriaMap.decodeFromJSONString($0) }
        self.schemaVersion   = record["schemaVersion"] as? String ?? "1.0"
        self.createdAt       = record.creationDate ?? Date()
        self.modifiedAt      = record.modificationDate ?? Date()
    }
}
```

Analogous extensions for `PendingContract` and `UserProfile` follow the same pattern.

**`CKMappingError`** (define in the Adapters layer):
```swift
enum CKMappingError: Error {
    case missingRequiredField(String)
    case jsonDecodingFailed(String, underlyingError: Error)
    case unsupportedSchemaVersion(String)
}
```

---

## Alternatives Considered

### Alternative 1: One CK Field Per Contract Field

Promote every field from `catalog.json` to a top-level CK field.

**Rejected:** 22 categories × ~8 fields = ~176 CK field definitions. Every `catalog.json` addition requires a CloudKit Dashboard schema migration. Arrays of objects (`depot.positions[]`) have no native CK representation anyway — requiring a JSON blob regardless. Complexity far exceeds benefit.

### Alternative 2: Separate `ContractFields` Record Type

Store `fieldsJSON` as a child `CKRecord` with a `CKRecord.Reference` parent link.

**Rejected:** Adds a second record type with a reference relationship. Fetching a contract requires two CloudKit operations (fetch parent, fetch child) or a `CKQueryOperation` on the reference — doubling latency for zero structural benefit. The `fieldsJSON` fits in a single field well under the 1 MB record limit.

### Alternative 3: CKAsset for `rawOCRText`

Store the OCR text in a `CKAsset` (a separate binary blob attachment).

**Rejected:** CKAsset requires a separate upload/download operation. At ~3–20 KB per document, the overhead is disproportionate. CKAsset is appropriate above ~100 KB. String field is simpler, visible in the Dashboard, and adequate at this size.

### Alternative 4: Update-in-Place for PendingContract → Contract Promotion

Reuse the same CKRecord, adding confirmed fields and changing a `status` field.

**Rejected:** CloudKit does not allow changing a record's `recordType`. A `PendingContract` record that "becomes" a `Contract` would retain all PendingContract fields (including `rawOCRText`) permanently. This creates semantic pollution and wastes storage. The delete+create approach is clean, atomic, and structurally honest.

### Alternative 5: Local-Only PendingContracts (UserDefaults or in-memory)

Store `PendingContract` only in device memory or `UserDefaults`, not in CloudKit.

**Rejected:** Decision D2 (2026-06-26) explicitly chose CloudKit storage for PendingContracts so that an OCR scan started on one device can be reviewed on another (e.g., iPhone scan → iPad review). Local-only would also lose the pending review on app restart, which is a poor UX when OCR takes time.

---

## Consequences

### Positive
- Zero backend server cost.
- EU data residency via iCloud Private Database (Apple DPA).
- Delta sync via `CKFetchRecordZoneChangesOperation` — bandwidth proportional to changes, not total data.
- `fieldsJSON` means `catalog.json` can add fields without CloudKit Dashboard schema changes.
- `probe()` detects zone-creation failures, permission errors, and network unavailability at startup before the user attempts a save.
- Atomic confirm flow (delete PendingContract + save Contract in one `CKModifyRecordsOperation`) eliminates orphan states.

### Negative
- `fieldsJSON` is not queryable server-side. Client-side aggregation required. Acceptable at 10–30 records.
- CKRecord mapping code is verbose (explicit field-by-field encode/decode). Mitigated by the `CKRecord.init(contract:)` and `Contract.init(record:)` extension pattern.
- CloudKit is Apple-platform-only. Android product (if built) cannot share this layer. Accepted per CLAUDE.md.
- CloudKit Dashboard schema must be manually configured (indexes). No code-driven schema management. A `CLOUDKIT_SCHEMA.md` document should track the expected Dashboard state.

### Neutral
- Schema is created on first app run. No migration script for Stage 1.
- `schemaVersion: "1.0"` is set from day one, enabling future `ContractMigrator` without retrofitting.

---

## Y-Statement Summary

In the context of a solo-developer iOS app requiring private, EU-resident contract storage, facing CloudKit's lack of native nested-object support and semi-structured contract fields across 22 categories, we decided for a hybrid CKRecord schema (promoted scalar fields for aggregation + `fieldsJSON` blob for category-specific data) with a custom zone (`FinanzAppZone`) for delta sync, and a delete-and-create promotion path for `PendingContract`, to achieve zero backend cost, zero schema-churn on catalog updates, and atomically consistent state transitions, accepting that server-side field queries are unavailable and record mapping code is verbose.
