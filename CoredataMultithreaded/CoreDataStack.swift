import Foundation
import CoreData

class CoreDataStack {
  func newPrivateQueueContext() -> NSManagedObjectContext? {
    let parentContext = self.mainQueueContext
    
    if parentContext == nil {
      return nil
    }
    
    let privateQueueContext =
      NSManagedObjectContext(concurrencyType:
        .PrivateQueueConcurrencyType)
    privateQueueContext.parentContext = parentContext
    privateQueueContext.mergePolicy =
      NSMergeByPropertyObjectTrumpMergePolicy
    return privateQueueContext
  }
  
  lazy var mainQueueContext: NSManagedObjectContext? = {
    let parentContext = self.masterContext
    
    if parentContext == nil {
      return nil
    }
    
    var mainQueueContext =
      NSManagedObjectContext(concurrencyType:
        .MainQueueConcurrencyType)
    mainQueueContext.parentContext = parentContext
    mainQueueContext.mergePolicy =
      NSMergeByPropertyObjectTrumpMergePolicy
    return mainQueueContext
  }()
  
  private lazy var masterContext: NSManagedObjectContext? = {
    let coordinator = self.persistentStoreCoordinator
    
    if coordinator == nil {
      return nil
    }
    
    var masterContext =
      NSManagedObjectContext(concurrencyType:
        .PrivateQueueConcurrencyType)
    masterContext.persistentStoreCoordinator = coordinator
    masterContext.mergePolicy =
      NSMergeByPropertyObjectTrumpMergePolicy
    return masterContext
  }()
  
  // MARK: - Setting up Core Data stack
  
  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = NSBundle.mainBundle().URLForResource("CoredataMultithreaded", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoredataMultithreaded")
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application's saved data."
    
    do {
      try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch var error1 as NSError {
      error = error1
      coordinator = nil
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      
      print("Unresolved error \(error), \(error!.userInfo)")
      exit(1)
    } catch {
      fatalError()
    }
    
    return coordinator
  }()
  
  private lazy var applicationDocumentsDirectory: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] 
  }()
  
  private func saveContext () {
    if let moc = self.mainQueueContext {
      var error: NSError? = nil
      if moc.hasChanges {
        do {
          try moc.save()
        } catch let error1 as NSError {
          error = error1
          print("Unresolved error \(error), \(error!.userInfo)")
          exit(1)
        }
      }
    }
  }
}
