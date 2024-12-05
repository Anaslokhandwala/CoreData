//
//  ViewController.swift
//  CoreData
//
//  Created by Mac on 05/12/24.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var dataTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTF.delegate = self
        mobileTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @IBAction func saveData(_ sender: UIButton) {
        guard let name = nameTF.text, !name.isEmpty,
              let password = passwordTF.text, !password.isEmpty,
              let email = emailTF.text, !email.isEmpty,
              let mobile = mobileTF.text, !mobile.isEmpty else {
            // Alert for empty fields
            showAlert(message: "Please fill all the fields.")
            return
        }
        var oldData:[[String:Any]] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            for data in result as! [NSManagedObject] {
                if let username = data.value(forKey: "username") as? String,
                   let email = data.value(forKey: "email") as? String,
                   let password = data.value(forKey: "password") as? String,
                   let mobile = data.value(forKey: "mobileno") as? String {
                    
                    let data = ["name": username, "password": password, "email": email, "number": mobile]
                    oldData.append(data)
                }
            }
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
        
        // Prepare data to save
        let data = [["name": name, "password": password, "email": email, "number": mobile]]
//        oldData.append(data)
        // Save data in Core Data
        createData(data: data)
        
        // Clear text fields after saving
        clearTextFields()
        
        // Retrieve and update the display
        retriveData(entityName: "Users")
    }

    func clearTextFields() {
        nameTF.text = ""
        passwordTF.text = ""
        emailTF.text = ""
        mobileTF.text = ""
    }



    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
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


}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
