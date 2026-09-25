import XCTest
@testable import StorageCore

final class UserDefaultsStoreTests: XCTestCase {
    private struct Value: Codable, Sendable, Equatable {
        let name: String
    }

    func test_missingPrimitiveThrowsNotFound() async {
        let suiteName = "UserDefaultsStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let store = UserDefaultsStore(defaults: defaults)

        do {
            let _: Bool = try await store.get(Bool.self, for: StorageKey("missing"))
            XCTFail("Expected notFound")
        } catch let error as StorageError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_typeMismatchDoesNotCrash() async {
        let suiteName = "UserDefaultsStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.set("not-an-int", forKey: "value")
        let store = UserDefaultsStore(defaults: defaults)

        do {
            let _: Int = try await store.get(Int.self, for: StorageKey("value"))
            XCTFail("Expected decoding error")
        } catch let error as StorageError {
            XCTAssertEqual(error, .decoding)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
