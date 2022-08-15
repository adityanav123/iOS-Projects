//
//  DetailsViewController.swift
//  MemeBookProject
//
//  Created by Aditya Navphule on 13/08/22.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var MemeImage: UIImageView!
    @IBOutlet weak var MemeName: UITextField!
    @IBOutlet weak var MemeCreator: UITextField!
    @IBOutlet weak var CreationYear: UITextField!
    
    @IBOutlet weak var saveButton: UIButton! // chosen as outlet, rather than action, so that we can reach the save button from any outlet
    
    var chosenMeme = ""
    var chosenMemeID : UUID? // for retrieving data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenMeme != "" {
            
            // save button disabled
            saveButton.isHidden = true
//            MemeName.isEnabled = false
//            CreationYear.isEnabled = false
//            MemeCreator.isEnabled = false
            
            // retrieve data from core data
            // id is given : MemeID
//            let stringUUID = chosenMemeID?.uuidString // converted to string
//            print(stringUUID)
            
            // retrieving data
            let appDeleate = UIApplication.shared.delegate as! AppDelegate
            let context = appDeleate.persistentContainer.viewContext
            
            // fetch request
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Memes")
            // add predicate --> Filter out the results with the above id
            
            let idString = chosenMemeID?.uuidString
            
            fetch.predicate = NSPredicate(format: "id = %@", idString!) // %@ -> regular expression
            fetch.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetch)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            MemeName.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            MemeCreator.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            CreationYear.text = String(year)
                        }
                        if let image = result.value(forKey: "image") as? Data {
                            // since image is stored as Binary Data
                            let img = UIImage(data: image)
                            MemeImage.image = img
                        }
                    }
                }
            }
            catch {
                print("error")
            }
            
            
        } else {
            saveButton.isEnabled = false
            saveButton.isHidden = false
            MemeName.text = ""
            MemeCreator.text = ""
            CreationYear.text = ""
        }
        
        // Stop the keyboard from accumulating space in the view
        // gesture recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer) // add the recognizer to the whole view
        
        
        // Recognizing when user taps the image.
        MemeImage.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        MemeImage.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    // gives us whether the user has picked the image or not. // returns dictionary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Any type : UIImage()
        MemeImage.image = info[.editedImage] as? UIImage // gets the edited image from the user. // optinal cast
        
        // enable save button
        saveButton.isEnabled = true
        
        // dismiss the picker controller
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectImage() {
        // Pick Image from photo library
        let picker = UIImagePickerController()
        picker.delegate = self // delegate(authorization) to the view controller
        
        // select the photo
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true // allow user to edit photo
        present(picker, animated: true, completion: nil) // like in the button in alerts
        
        // What happens when we choose the image?
    }
    
    @IBAction func SaveTheMeme(_ sender: Any) {
        print("Save Button Clicked")
        
        // save the context --> Reach the AppDelegate Function
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // gives us the instance of the app.
        let context = appDelegate.persistentContainer.viewContext // persistent Container = our core data is stayed in
        
        // write to database
        let newMeme = NSEntityDescription.insertNewObject(forEntityName: "Memes", into: context)
        
        // Attributes
        newMeme.setValue(MemeName.text!, forKey: "name")
        newMeme.setValue(MemeCreator.text!, forKey: "artist")
        if let year = Int(CreationYear.text!) {
            newMeme.setValue(year, forKey: "year")
        }
        newMeme.setValue(UUID(), forKey: "id") // Universal Unique ID
        
        // convert image to binary data. // as core data stores it in Binary Data Type.
        let data = MemeImage.image!.jpegData(compressionQuality: 0.5) // 50 % compression quality
            
        newMeme.setValue(data, forKey: "image")

        // error checking. with do try catch
        do {
            try context.save()
            print("successfully saved.")
        }
        catch {
            // alert message.
            print("error")
        }
        
        // take us back to the original view controller for viewing
        self.navigationController?.popViewController(animated: true)
        
        // notify the view controller that new data has been added, update yourself
        // sends the message to the app
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // end the editing
    }
    
}
