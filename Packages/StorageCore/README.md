# StorageCore

StorageCore exposes multiple persistence backends through focused protocols. `StorageFacade` groups those contracts without creating a singleton.

| Requirement | API | Typical data |
|---|---|---|
| Lightweight preferences | `KeyValueStore` / `UserDefaultsStore` | Theme, flags, last selection |
| Secrets | `SecureStore` / `KeychainStore` | Tokens and credentials |
| Rebuildable file cache | `DiskCache` | Encoded responses and images |
| Durable models | `DatabaseStore` / `CoreDataStore` | Codable records |

## Preferences and Keychain

```swift
let preferences = UserDefaultsStore()
let appearanceKey = StorageKey("appearance")
try await preferences.set("dark", for: appearanceKey)
let mode = try await preferences.get(String.self, for: appearanceKey)

let keychain = KeychainStore(service: "com.example.app.auth")
let tokenKey = StorageKey("access-token")
try await keychain.save(Data(token.utf8), for: tokenKey)
let tokenData = try await keychain.load(for: tokenKey)
try await keychain.delete(for: tokenKey)
```

Keychain uses `AfterFirstUnlockThisDeviceOnly`. Keep the service name stable, and never place secrets in UserDefaults, general database records, or logs.

## Disk cache and Core Data

```swift
let cache = DiskCache()
try await cache.save("feed", encodedPosts)
let cached = try await cache.load("feed")
try await cache.remove("feed")

let stack = try await CoreDataStack(modelName: "Model", inMemory: false)
let database = CoreDataStore(stack: stack)
try await database.save(user, id: user.id)
let restored = try await database.fetch(User.self, id: user.id)
try await database.delete(User.self, id: user.id)
```

CoreDataStore serializes Codable values into the generic `CDRecord` entity. Renaming a Swift type changes its storage type identifier, so production migrations should introduce explicit stable identifiers.

Use isolated UserDefaults suites, unique Keychain services, temporary cache directories, and in-memory Core Data stores in tests.
