//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Ford Labs on 10/07/19.
//  Copyright © 2019 Ford Labs. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: Meal?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field's user input through delegate callback
        nameTextField.delegate = self
        
        //Set Up views if editing an existing meal
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        updateSaveButton()
        
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // hide the keyword
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButton()
        navigationItem.title = textField.text
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        // set photoView to display the selected Image
        photoImageView.image = selectedImage
        
        // dismis the picker
        dismiss(animated: true, completion: nil)
    }
    
    // Mark: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending upon the type of presentation (push or modal) , this view controller need to be
        // dismissed deferently
        let presentingInAddMealMode = presentingViewController is UINavigationController
        
        if presentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else{
            fatalError("Error")
        }
        
    }
    
    
    // This method lets you to configure a view controller before it is presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is clicked
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let image = photoImageView.image
        let rating = ratingControl.rating
        
        // This meal info will be passed to MealTableViewController
        meal = Meal(name: name, photo: image, rating: rating)
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // this code ensures that if the user taps the image view while typing
        // in the text field, the keyboard is dismissed properly - hide keyboard
        nameTextField.resignFirstResponder()
        // UIImagePickerController lets user to pick a media from their photo library
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary // only allows photo to be picked
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    // MARK: Private Method
    func updateSaveButton(){
        let textOnField = nameTextField.text ?? ""
        saveButton.isEnabled = !textOnField.isEmpty
    }
}

