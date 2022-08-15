//
//  ViewController.swift
//  MemeBookProject
//
//  Created by Aditya Navphule on 13/08/22.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var TableView: UITableView!
    var nameArray = [String]()
    var IDArray = [UUID]()
    
    // segue the chosen image
    var selectedMeme = ""
    var selectedMemeID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        TableView.delegate = self
        TableView.dataSource = self
        
        // reac the top item, the are above the table
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // as viewDidLoad gets called once
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
    @objc func getData() {
        
        nameArray.removeAll(keepingCapacity: false)
        IDArray.removeAll(keepingCapacity: false)
        
        // retrieve data from core data database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // authorization
        let context = appDelegate.persistentContainer.viewContext // gives us context
        
        // retrieve data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Memes")
        fetchRequest.returnsObjectsAsFaults = false // not going to get object as faults, more efficient, [CAN SEARCH MORE on INTERNET]
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let currentName = result.value(forKey: "name")  as? String {
                        self.nameArray.append(currentName)
                    }
                    
                    if let currentID = result.value(forKey: "id") as? UUID {
                        self.IDArray.append(currentID)
                    }
                    self.TableView.reloadData() // refersh the table.
                }
            }
            
        }
        catch {
            print("error")
        }
        
    }
    
    
    
    @objc func addButtonClicked () {
        selectedMeme = ""
        performSegue(withIdentifier: "detailsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    // prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.chosenMeme = selectedMeme
            destinationVC.chosenMemeID = selectedMemeID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMeme = nameArray[indexPath.row]
        selectedMemeID = IDArray[indexPath.row]
        performSegue(withIdentifier: "detailsVC", sender: nil)
    }
    
    // Delete Functionality
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get the element from core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Memes")
            
            let uuidString = IDArray[indexPath.row].uuidString
            fetch.predicate = NSPredicate(format: "id = %@", uuidString)
            
            fetch.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetch)
                if results.count > 0 {
                    // delete the data entry
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == IDArray[indexPath.row] {
                                // checking if id retrieved is correct or not , just to be on the safe side
                                context.delete(result) // no turn backs
                                nameArray.remove(at: indexPath.row)
                                IDArray.remove(at: indexPath.row)
                                self.TableView.reloadData() // reloading data, as deleted.
                                
                                // save the current context again
                                do {
                                    try context.save()
                                }
                                catch {
                                    print("cannot save after deleting.")
                                }
                                break
                            }
                        }
                    }
                }
            }
            catch {
                print("error")
            }
           
        }
    }
    
}

