@testable import BaseCore
import Testing

struct LoggerTests {
    @Test func writesRecordsAtOrAboveMinimumLevel() {
        let destination = RecordingDestination()
        let logger = Logger(minimumLevel: .info, destination: destination)

        logger.log(.debug, "Ignored")
        logger.log(.error, "Saved", file: "Feature.swift", function: "load()", line: 42)

        let records = destination.records.snapshot()
        #expect(records.count == 1)
        #expect(records.first?.level == .error)
        #expect(records.first?.message == "Saved")
        #expect(records.first?.file == "Feature.swift")
        #expect(records.first?.line == 42)
    }
}

private final class RecordingDestination: LogDestination, @unchecked Sendable {
    let records = LockIsolated<[LogRecord]>([])

    func write(_ record: LogRecord) {
        records.withValue { $0.append(record) }
    }
}
