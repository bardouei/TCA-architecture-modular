//
//  CoreDataStack.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation
import CoreData

public final class CoreDataStack: @unchecked Sendable {

    public let container: NSPersistentContainer

    public init(modelName: String, inMemory: Bool = false) async throws {
        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw StorageError.underlying("CoreData model '\(modelName)' was not found in StorageCore resources")
        }
        container = NSPersistentContainer(name: modelName, managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let error {
                    continuation.resume(throwing: StorageError.underlying("CoreData load failed: \(error)"))
                } else {
                    continuation.resume()
                }
            }
        }

        let viewContext = container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.automaticallyMergesChangesFromParent = true
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return ctx
    }
}
