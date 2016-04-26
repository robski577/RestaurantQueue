//
//  AddPartyViewController.swift
//  RestaurantQueue
//
//  Created by Mason Elmore on 4/21/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import UIKit

class AddReservationViewController: UIViewController {

    static var delegate: passReservationBackToPreviousViewControllerDelegate!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Event Handlers
    
    // Add a new reservation to the list and leave the view when the Add button is clicked.
    @IBAction func addButtonClicked(sender: UIButton) {
        if isValidData() {
            let name = nameTextField.text
            let size = Int(sizeTextField.text!)
            let reservation = Reservation(name: name!, size: size!)
            AddReservationViewController.delegate.passReservationBackToPreviousViewController(reservation)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    // MARK: Data Validation
    
    // Return true if all of the input is valid.
    private func isValidData() -> Bool {
        return
            isPresent(nameTextField, name: "Name") &&
            isPresent(sizeTextField, name: "Size") &&
            isInteger(sizeTextField, name: "Size") //&&
//            isPresent(waitTimeTextField, name: "Wait Time") &&
//            isInteger(waitTimeTextField, name: "Wait Time")
    }
    
    // Return true if a UITextField isn't nil or empty.
    private func isPresent(textField: UITextField, name: String) -> Bool {
        if textField.text == nil || textField.text == "" {
            showAlert("Required Field", message: "\(name) is a required field.")
            // TODO: Move focus to the text field.  The following line does not work properly.
            //textField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
    // Return true if a UITextField contains a valid Integer
    private func isInteger(textField: UITextField, name: String) -> Bool {
        if let _ = Int(textField.text!) {
            return true
        }
        
        showAlert("Invalid Input", message: "\(name) must be a positive integer")
        // TODO: Move focus to the text field.  The following line does not work properly.
        //textField.becomeFirstResponder()
        return false
    }
    
    
    // MARK: Helper Functions
    
    // Pop up an alert for the user.
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
