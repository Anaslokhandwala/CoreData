# CoreData Integration in iOS

This guide provides an overview of how to implement CoreData in an iOS project. It includes methods for creating, retrieving, updating, and deleting data in CoreData.

---

## Changes in AppDelegate

Add the following code to your `AppDelegate` for setting up the `persistentContainer`:

```swift
lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreData")
    container.loadPersistentStores { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    return container
}()

func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
```

---

## To Create a data 

```swift
    func createData(data:[[String:Any]]){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "Users", in: managedContext)
        
        for i in data {
            
            let user = NSManagedObject(entity: userEntity!, insertInto: managedContext)
            user.setValue("\(i["name"] ?? "")", forKey: "username")
            user.setValue("\(i["email"] ?? "")", forKey: "email")
            user.setValue("\(i["number"] ?? "")", forKey: "mobileno")
            user.setValue("\(i["password"] ?? "")", forKey: "password")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("\(error)")
            }
        }
        
    }
```

---
## To Get Data

```swift
    func retriveData(entityName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            var displayText = ""
            dataTV.text = ""
            for data in result as! [NSManagedObject] {
                if let username = data.value(forKey: "username") as? String,
                   let email = data.value(forKey: "email") as? String,
                   let mobile = data.value(forKey: "mobileno") as? String {
                    displayText += "Name: \(username), Email: \(email), Mobile: \(mobile)\n"
                }
            }
            dataTV.text = displayText
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
    }
```

---
## To Update Data

```swift
    func updateData(name:String,data:[String:Any]){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Users")
        fetchRequest.predicate = NSPredicate(format: "username = %@", name)
        do{
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue(data["name"], forKey: "username")
            objectUpdate.setValue(data["email"], forKey: "email")
            objectUpdate.setValue(data["number"], forKey: "mobileno")
            objectUpdate.setValue(data["password"], forKey: "password")
            do{
                try managedContext.save()
            }catch {
                print(error)
            }
        }catch{
            print(error)
        }
        
    }
```

---
## To Delete Data

```swift 
    func deleteData(name:String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Users")
        
        fetchRequest.predicate = NSPredicate.init(format: "username == %@", name)
        
        do{
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
            }catch{
                print(error)
            }
            
        }catch {
            print(error)
        }
    }
```

