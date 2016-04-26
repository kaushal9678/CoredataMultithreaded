import CoreData

extension NSManagedObjectContext {
  func saveRecursively() {
    performBlockAndWait {
      if self.hasChanges {
        self.saveThisAndParentContexts()
      }
    }
  }
  
  func saveThisAndParentContexts() {
    var error: NSError? = nil
    let successfullySaved: Bool
    do {
      try save()
      successfullySaved = true
    } catch let error1 as NSError {
      error = error1
      successfullySaved = false
    }
    
    if successfullySaved {
      parentContext?.saveRecursively()
    } else {
      print("Error: \(error!.localizedDescription)")
    }
  }
}
