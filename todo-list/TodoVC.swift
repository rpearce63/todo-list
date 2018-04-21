//
//  ViewController.swift
//  todo-list
//
//  Created by Rick on 4/20/18.
//  Copyright © 2018 Pearce. All rights reserved.
//

import UIKit
import CoreData

class TodoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var todoTextField: UITextField!
    
    //var todoList : [String] = []
    var todos : [NSManagedObject] = []
    var appDelegate : AppDelegate?
    var managedContext : NSManagedObjectContext?
    var entity : NSEntityDescription?
    var selectedRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configureCoreData()
        fetchTodoData()
    }

   

    @IBAction func addBtnPressed(_ sender: Any) {
        if todoTextField.text != "" {
            saveData(title: todoTextField.text!)
            tableView.reloadData()
            todoTextField.text = ""
        }
    }
    
    func configureCoreData() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        //1
        managedContext = appDelegate?.persistentContainer.viewContext
        
        entity = NSEntityDescription.entity(forEntityName: "Todo", in: managedContext!)
    }
    
    func addNewRow(todo: Todo) {
        
    }
    
    func removeTodoFromCoreData(todo: NSManagedObject) {
        managedContext?.delete(todo)
        do {
            try managedContext?.save()
        } catch {
            print(error)
        }
    }
    
    func saveData(title: String) {
        
//        //UserDefaults.standard.set(todoList, forKey: "todoList")
//
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//         //1
//        let managedContext = appDelegate.persistentContainer.viewContext
//        //2
//        let entity = NSEntityDescription.entity(forEntityName: "Todo", in: managedContext)
        //3
        let newTodo = NSManagedObject(entity: entity!, insertInto: managedContext)
        newTodo.setValue(title, forKeyPath: "title")
        //4
        do {
            try managedContext?.save()
            todos.append(newTodo)
        } catch {
            print(error)
        }
        
        
    }
    
    func fetchTodoData() {
        
//        if let savedTodos = UserDefaults.standard.array(forKey: "todoList") {
//            todoList = savedTodos
//        }
        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let manageContext = appDelegate.persistentContainer.viewContext
//
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        
        do {
            todos = try managedContext!.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }

    func updateRecord() {
        let todo = todos[selectedRow!]
        do {
        
           try managedContext?.existingObject(with: todo.objectID).setValue(true, forKey: "status")
                try managedContext?.save()
        } catch {
            print(error)
        }
        
    }
    
    @objc func doubleTap() {
        //print("Double tapped \(String(describing: todos[selectedRow!].value(forKey: "title")))")
        let cell = tableView.cellForRow(at: IndexPath(row: selectedRow!, section: 0))
        if cell?.textLabel?.textColor == UIColor.black {
            cell?.textLabel?.textColor = UIColor.red
            (todos[selectedRow!] as! Todo).status = true
        } else {
            cell?.textLabel?.textColor = UIColor.black
            (todos[selectedRow!] as! Todo).status = false
        }
        updateRecord()
    }
    
    // Tableview methods
    
    // indicates the number of data sections in a table. Usually just one, which is the default
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    // indicates the number of rows in the table, usually equal to items in a collection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    // builds content for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let todo = todos[indexPath.row]
        cell.textLabel?.text = todo.value(forKey: "title") as? String
        if todo.value(forKey: "status") as! Bool  {
            cell.textLabel?.textColor = UIColor.red
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTapsRequired = 2
        cell.addGestureRecognizer(tap)
        return cell
    }
    
    // enables swipe and delete for a row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoRemoved = todos[indexPath.row]
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            removeTodoFromCoreData(todo: todoRemoved)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
    }
    
}

