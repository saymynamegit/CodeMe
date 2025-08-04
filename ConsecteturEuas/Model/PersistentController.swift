import Foundation
import CoreData
import SwiftUI
import Combine

class PersistentController: ObservableObject {
    static let shared = PersistentController()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EditedImage")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func deleteAll() {
        let context = container.viewContext
        
        // Get all entity names from the managed object model
        let entities = container.managedObjectModel.entities
        
        for entity in entities {
            guard let entityName = entity.name else { continue }
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Delete all error for entity \(entityName): \(error)")
            }
        }
        
        // Save the context to persist the changes
        save()
    }
    
    // Alternative method to delete all objects of a specific entity
    func deleteAll<T: NSManagedObject>(ofType type: T.Type) {
        let context = container.viewContext
        let entityName = String(describing: type)
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            save()
        } catch {
            print("Delete all error for \(entityName): \(error)")
        }
    }
    
    private init() {}
}
