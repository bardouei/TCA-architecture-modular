//
//  CoreDataStore.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation
import CoreData

@available(iOS 15.0, *)
public actor CoreDataStore: DatabaseStore {
    
    private let stack: CoreDataStack
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(stack: CoreDataStack) {
        self.stack = stack
    }
    
    // MARK: - Save
    
    public func save<T>(_ object: T, id: String) async throws
    where T: Encodable & Decodable {
        
        let context = stack.newBackgroundContext()
        let typeName = String(describing: T.self)
        
        do {
            let data = try encoder.encode(object)
            
            try await context.perform {
                let request = NSFetchRequest<NSManagedObject>(entityName: "CDRecord")
                request.fetchLimit = 1
                request.predicate = NSPredicate(
                    format: "id == %@ AND type == %@",
                    id, typeName
                )
                
                let record = try context.fetch(request).first
                ?? NSManagedObject(
                    entity: NSEntityDescription.entity(
                        forEntityName: "CDRecord",
                        in: context
                    )!,
                    insertInto: context
                )
                
                record.setValue(id, forKey: "id")
                record.setValue(typeName, forKey: "type")
                record.setValue(data, forKey: "payload")
                record.setValue(Date(), forKey: "updatedAt")
                
                if context.hasChanges {
                    try context.save()
                }
            }
            
        } catch {
            throw StorageError.underlying("CoreData save failed: \(error)")
        }
    }
    
    // MARK: - Fetch
    
    public func fetch<T: Sendable>(_ type: T.Type, id: String) async throws -> T
    where T: Encodable & Decodable {
        
        let context = stack.newBackgroundContext()
        let typeName = String(describing: T.self)
        
        do {
            return try await context.perform {
                let request = NSFetchRequest<NSManagedObject>(entityName: "CDRecord")
                request.fetchLimit = 1
                request.predicate = NSPredicate(
                    format: "id == %@ AND type == %@",
                    id, typeName
                )
                
                guard
                    let record = try context.fetch(request).first,
                    let data = record.value(forKey: "payload") as? Data
                else {
                    throw StorageError.notFound
                }
                
                do {
                    return try self.decoder.decode(T.self, from: data)
                } catch {
                    throw StorageError.decoding
                }
            }
            
        } catch let error as StorageError {
            throw error
        } catch {
            throw StorageError.underlying("CoreData fetch failed: \(error)")
        }
    }
    
    // MARK: - Delete
    
    public func delete<T>(_ type: T.Type, id: String) async throws {
        
        let context = stack.newBackgroundContext()
        let typeName = String(describing: T.self)
        
        do {
            try await context.perform {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDRecord")
                request.predicate = NSPredicate(
                    format: "id == %@ AND type == %@",
                    id, typeName
                )
                
                let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
                batchDelete.resultType = .resultTypeObjectIDs
                
                let result = try context.execute(batchDelete) as? NSBatchDeleteResult
                
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                        into: [self.stack.container.viewContext]
                    )
                }
            }
        } catch {
            throw StorageError.underlying("CoreData delete failed: \(error)")
        }
    }
}
