RestaurantQueue
===============

This project is designed to operate with a iPhone/iPad and an AppleTV,
the phone operating as a controller and the TV displaying the
information.

The phone or tablet would be used by a host in a resteraunt to manage
people requesting a table during a wait.  These reservations
are then displayed on an AppleTV for the patrons to know
the current average wait and when their table is ready

#### ViewControlllers
##### iOS Views
###### main view
These variables are used to hold our current reservations
and supply the two different sets of reservations for the 
two different sections of the table view
``` swift
var reservations = [Reservation]()
var readyReservations: [Reservation] {
    get {
        return reservations.filter( { $0.isReady } )
    }
}
var waitingReservations: [Reservation] {
    get {
        return reservations.filter( { !$0.isReady } )
    }
}
```

when the view initially loads we need to add the long press gesture recognizer
this is used to set the reservation ready to be seated and remove it
it also add a timer to the main run loop that will update our
tableview.  This is required because iOS will not allow an interface
to be updated from an async thread.  
``` swift 
override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate for passing back reservation information
        AddReservationViewController.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ReservationListViewController.longPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        longPress.delaysTouchesBegan = true
        self.reservationTableView.addGestureRecognizer(longPress)
        viewUpdateTimer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(checkReservations), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(viewUpdateTimer, forMode: NSDefaultRunLoopMode)
    }
```
this is the method that the timer calls to, it check to make sure the reservation arrays
match the table view, if it does not it will call the reloadData method.
``` swift
func checkReservations() {
        if reservationTableView.numberOfRowsInSection(readySectionIndex) == readyReservations.count &&
            reservationTableView.numberOfRowsInSection(waitingSectionIndex) == waitingReservations.count {
            return
        }
        reservationTableView.reloadData()
    }
```
this method is used by the addReservation view to pass the information 
back to the main controller
``` swift
func reservationAddedNotification(name: String, size: Int) {
        addReservation(name, size: size)
    }
```
these methods are used to call on the DataHelper to interact 
with the server
``` swift 
func retrieveReservations() {
        DataHelper.requestReservations{ response, error in
            if error == nil {
                self.reservations = response!
            }
        }
    }
    
func sendRemovalRequest(id: Int) {
    DataHelper.removeReservation(id) {response, error in
        if error == nil {
            self.reservations = response!
        }
    }
}
    
func sendSeatRequest(id: Int) {
    DataHelper.seatReservation(id) { response, error in
        if error == nil {
            self.reservations = response!
        }
    }
}

func addReservation(name: String, size: Int) {
  DataHelper.postReservation(name, partySize: size) { reservations, error in
        if error == nil {
            self.reservations = reservations!
        }
    }
}
```
###### Add Reservation View
This view lets the user add a new reservation to the queue.  The method below is called when the user clicks the "Add" button after filling out the name and number of people for the new reservation.  First we check if the data is valid.  If it is, we create a new reservation object and pass it back to the main view.
``` swift
@IBAction func addButtonClicked(sender: UIButton) {
  if isValidData() {
    let name = nameTextField.text
    let size = Int(sizeTextField.text!)
    let reservation = Reservation(name: name!, size: size!)
          
    AddReservationViewController.delegate.passReservationBackToPreviousViewController(reservation)
    self.navigationController?.popViewControllerAnimated(true)
  }
}
```
The following code handles the input validation.  If the user enteres invalid data, an alert will pop up letting them know how to fix it.
``` swift 
private func isValidData() -> Bool {
      return
      isPresent(nameTextField, name: "Name") &&
      isPresent(sizeTextField, name: "Size") &&
      isInteger(sizeTextField, name: "Size") //&&
//    isPresent(waitTimeTextField, name: "Wait Time") &&
//    isInteger(waitTimeTextField, name: "Wait Time")
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

private func showAlert(title: String, message: String) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
  let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
  alertController.addAction(alertAction)
  self.presentViewController(alertController, animated: true, completion: nil)
}
```
The main view implements this protocol to get the reservation information from the Add Reservation view.  It gets added as a delegate to the Add Reservation view in the Main view loads.
``` swift 
// This is used to passing back the reservation information back to the previous view controller 😉
protocol passReservationBackToPreviousViewControllerDelegate {
    func passReservationBackToPreviousViewController(reservation: Reservation)
}
```
##### tvOS Views
``` swift

```

#### DataHelper
``` swift

```

#### Reservation
``` swift

```
