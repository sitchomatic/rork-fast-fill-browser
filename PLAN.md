# Part 2: Persistence Layer & Explicit Sendable DTOs

## Overview
Upgrade the SwiftData models with compound unique constraints and proper data types, then create matching Sendable DTO structs with pure mapping functions for safe cross-boundary data transfer.

---

### 1. Upgrade `Credential` Model
- Keep `@Attribute(.unique)` on `id` as the primary key
- Add `#Unique<Credential>([\.domain, \.username])` compound constraint for upsert behavior on domain+username
- Change `totpSecret` from `String?` to `Data?` for memory-safe storage
- Add `#Index` on frequently queried fields (`domain`, `lastUsedAt`)

### 2. Upgrade `SiteSetting` Model
- Add `#Index<SiteSetting>([\.domain])` for fast lookups
- Keep existing `@Attribute(.unique)` on `domain`

### 3. Upgrade `BrowsingHistoryEntry` Model
- Add `#Index<BrowsingHistoryEntry>([\.visitedAt], [\.domain])` for efficient history queries

### 4. Upgrade `Bookmark` Model
- Add `#Index<Bookmark>([\.sortOrder], [\.domain])` for ordered fetches

### 5. Create `CredentialDTO`
- `nonisolated struct CredentialDTO: Sendable`
- All fields mirrored from the model, but `totpSecret` stored as `[UInt8]?` (not `String` or `Data`) to prevent heap leaks
- Includes `id`, `domain`, `username`, `notes`, `totpSecret`, `createdAt`, `updatedAt`, `lastUsedAt`, `usageCount`
- Computed `displayDomain` property

### 6. Create `SiteSettingDTO`
- `nonisolated struct SiteSettingDTO: Sendable`
- All fields mirrored from the model

### 7. Create `BrowsingHistoryEntryDTO`
- `nonisolated struct BrowsingHistoryEntryDTO: Sendable`
- All fields mirrored from the model

### 8. Create `BookmarkDTO`
- `nonisolated struct BookmarkDTO: Sendable`
- All fields mirrored from the model

### 9. Pure Mapping Functions
- Each DTO gets a `nonisolated` initializer that takes the corresponding `@Model` instance: `init(from model: Credential)`
- Each `@Model` gets a static factory or extension method to create/update from its DTO
- All mapping functions are `nonisolated` and pure — no side effects, no context access
- `CredentialDTO.init(from:)` converts `Data? → [UInt8]?` for the TOTP secret
- Reverse mapping converts `[UInt8]? → Data?` when writing back to the model

### 10. Update Existing References
- Update `CredentialFormView`, `CredentialDetailView`, `ImportCredentialsView`, and `VaultViewModel` to handle `totpSecret` as `Data?` instead of `String?`
- Ensure the app still compiles and runs correctly after model changes

---

### Files Created
- `DTOs/CredentialDTO.swift`
- `DTOs/SiteSettingDTO.swift`
- `DTOs/BrowsingHistoryEntryDTO.swift`
- `DTOs/BookmarkDTO.swift`

### Files Modified
- `Models/Credential.swift` — compound unique, Data? totpSecret, index
- `Models/SiteSetting.swift` — index
- `Models/BrowsingHistoryEntry.swift` — index
- `Models/Bookmark.swift` — index
- Views/ViewModels referencing `totpSecret` as `String?` — update to `Data?`
