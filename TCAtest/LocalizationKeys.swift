import Foundation

/// Registers localizable resources used by package-based features in the app target.
///
/// Swift Package views resolve these values from the main bundle. Keeping the keys
/// here also lets Xcode extract them into the app's String Catalog.
enum AppLocalizationKeys {
    static let all: [LocalizedStringResource] = [
        "Home",
        "Refresh",
        "Opens post details",
        "No Posts",
        "Pull to refresh or try again later.",
        "Something went wrong",
        "Retry",
        "Check your internet connection and try again.",
        "Check your connection and try again.",
        "The received data could not be read.",
        "Posts are temporarily unavailable.",
        "Loading...",
        "Post",
        "Explore",
        "Modules",
        "Products unavailable",
        "Search products",
        "The catalog is temporarily unavailable.",
        "The server response could not be read.",
        "Opens product details",
        "Remove Favorite",
        "Add to Favorites",
        "Product",
        "Module Showcase",
        "Appearance",
        "Language",
        "Choose English or German.",
        "English",
        "German",
        "System",
        "Light",
        "Dark",
        "Switch between system, light, and dark appearance live.",
        "DesignSystem",
        "Tokens, cards, buttons, badges, loading, and empty states.",
        "Large title",
        "Semantic text that supports Dynamic Type",
        "Primary Button",
        "Secondary Button",
        "Destructive Button",
        "Empty State",
        "A shared empty-state example for features.",
        "Info",
        "Success",
        "Warning",
        "Error",
        "NetworkCore",
        "All operations run with async/await.",
        "Single request",
        "Concurrent requests",
        "Sequential requests",
        "Priority queue",
        "Network Cache",
        "Download one image",
        "Download multiple images",
        "Upload file",
        "Downloaded files",
        "StorageCore",
        "Preferences, DiskCache, Keychain, Core Data, and Facade.",
        "UserDefaults and DiskCache",
        "Complete Keychain flow",
        "Core Data and StorageFacade",
        "Ready to run",
        "Running…",
        "Loading…",
        "UserDefaults and DiskCache: save, read, existence check, and removal succeeded",
        "Keychain: secure save, existence check, read, and removal succeeded",
        "StorageFacade and Core Data: save, fetch, and delete succeeded"
    ]

    static func singleRequest(statusCode: Int, title: String) -> LocalizedStringResource {
        "GET /posts/1 → \(statusCode); \(title)"
    }

    static func concurrentRequests(count: Int) -> LocalizedStringResource {
        "5 concurrent requests (limit 3); \(count) successful responses"
    }

    static func sequentialRequests(statusCodes: String) -> LocalizedStringResource {
        "3 sequential requests; status codes: \(statusCodes)"
    }

    static func priorityQueue(count: Int) -> LocalizedStringResource {
        "Priority queue; \(count) responses and zero active/pending operations"
    }

    static func networkCache(byteCount: Int) -> LocalizedStringResource {
        "NetworkCache; \(byteCount) bytes stored, read, and removed"
    }

    static func singleDownload(fileName: String) -> LocalizedStringResource {
        "Single download completed; \(fileName)"
    }

    static func multipleDownloads(count: Int) -> LocalizedStringResource {
        "Concurrent download of \(count) images completed"
    }

    static func upload(statusCode: Int) -> LocalizedStringResource {
        "File upload → HTTP \(statusCode)"
    }

    static func operationFailed(error: String) -> LocalizedStringResource {
        "Operation failed: \(error)"
    }
}
