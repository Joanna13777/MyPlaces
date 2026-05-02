

import UIKit
import CoreData

class CoreDataStack {
    
    
    let modelName: String

        init(modelName: String) {
            self.modelName = modelName
        }
    
    lazy var persistentContainer: NSPersistentContainer = {
           // Используем self.modelName вместо "MyPlaces"
           let container = NSPersistentContainer(name: self.modelName)
           
           // Включаем автоматическую миграцию (полезно, если вы добавите новые поля в базу)
           let description = container.persistentStoreDescriptions.first
           description?.shouldMigrateStoreAutomatically = true
           description?.shouldInferMappingModelAutomatically = true
           
           container.loadPersistentStores(completionHandler: { (storeDescription, error) in
               if let error = error as NSError? {
                   fatalError("Unresolved error \(error), \(error.userInfo)")
               }
           })
        return container
    }()

        // Контекст для работы с данными
        var context: NSManagedObjectContext {
            return persistentContainer.viewContext
        }

        // MARK: - Core Data Saving support
    func saveContext() {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
