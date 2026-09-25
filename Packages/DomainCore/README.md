# DomainCore

DomainCore contains framework-independent business models and contracts. It follows Clean Architecture: entities and value objects form the center, repository protocols define boundaries, and use cases coordinate business rules.

## Components

- `User` and `EntityPost`: Codable, Equatable, Identifiable, and Sendable entities.
- `Email`: a value object that rejects invalid input during initialization.
- `UserRepository`: the user data contract.
- `GetUserUseCase` and `GetUserUseCaseImpl`: business-level user retrieval.
- `DomainError`: meaningful domain failures.

```swift
struct LiveUserRepository: UserRepository {
    func getUser(id: String) async throws -> User {
        User(id: id, name: "Sample", email: try Email("sample@example.com"))
    }
}

let useCase = GetUserUseCaseImpl(repository: LiveUserRepository())
let user = try await useCase.execute(userId: "42")
```

Network DTOs and `NSManagedObject` subclasses must not enter this module. Map infrastructure models to domain entities at repository boundaries.
