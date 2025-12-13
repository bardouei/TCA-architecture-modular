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

    public init(modelName: String, inMemory: Bool = false) {
        container = NSPersistentContainer(name: modelName)

        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData load error: \(error)")
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
