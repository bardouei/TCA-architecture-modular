import Foundation

public protocol TokenProviderProtocol: Actor {
    var currentToken: String? { get }
    func isTokenExpired(_ token: String) -> Bool
    func refreshToken() async throws -> String
    func updateToken(_ token: String) async
}

public actor InMemoryTokenProvider: TokenProviderProtocol {
    public typealias RefreshOperation = @Sendable () async throws -> String

    private var token: String?
    private var expirationDate: Date?
    private let tokenLifetime: TimeInterval
    private let refreshOperation: RefreshOperation

    public var currentToken: String? {
        token
    }

    public init(
        initialToken: String? = nil,
        expirationDate: Date? = nil,
        tokenLifetime: TimeInterval = 3_600,
        refreshOperation: @escaping RefreshOperation
    ) {
        self.token = initialToken
        self.expirationDate = expirationDate
        self.tokenLifetime = tokenLifetime
        self.refreshOperation = refreshOperation
    }

    public func isTokenExpired(_ token: String) -> Bool {
        guard token == self.token, let expirationDate else { return true }
        return Date() >= expirationDate
    }

    public func refreshToken() async throws -> String {
        try Task.checkCancellation()
        return try await refreshOperation()
    }

    public func updateToken(_ token: String) {
        self.token = token
        expirationDate = Date().addingTimeInterval(tokenLifetime)
    }
}
