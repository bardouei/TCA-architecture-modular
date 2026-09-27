@testable import BaseCore
import Testing

struct CoreTypesTests {
    @Test func environmentsExposeExpectedPolicies() {
        #expect(AppEnvironment.production.isProduction)
        #expect(AppEnvironment.production.enablesVerboseLogging == false)
        #expect(AppEnvironment.staging.enablesVerboseLogging)
    }

    @Test func coreErrorsAreEquatableAndDescriptive() {
        #expect(CoreError.invalidURL == .invalidURL)
        #expect(CoreError.invalidURL.errorDescription?.isEmpty == false)
    }

    @Test func logLevelsAreOrdered() {
        #expect(LogLevel.debug < .warning)
        #expect(LogLevel.error < .critical)
    }
}
