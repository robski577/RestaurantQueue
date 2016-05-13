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
###### Main View
The one and only view on the TV displays a list of reservations currently waiting and ready to seat.  The reservations are updated periodically from the server.

Three different timers are started when the view loads: one to update the average wait time, another to update the table view contents, and one to sync with the server.
``` swift
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let averageTimer = NSTimer(timeInterval: 10.0, target: self, selector: #selector(calculateAverageWait), userInfo: nil, repeats: true)
    let tableViewTimer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(checkTableView), userInfo: nil, repeats: true)
    let reservationTimer = NSTimer(timeInterval: 5.0, target: self, selector: #selector(checkReservations), userInfo: nil, repeats: true)
    NSRunLoop.mainRunLoop().addTimer(tableViewTimer, forMode: NSDefaultRunLoopMode)
    NSRunLoop.mainRunLoop().addTimer(averageTimer, forMode: NSDefaultRunLoopMode)
    NSRunLoop.mainRunLoop().addTimer(reservationTimer, forMode: NSDefaultRunLoopMode)
}
```
These are the three functions that are called from the timers mentioned above.
``` swift
func calculateAverageWait() {
    guard reservations.count > 0 else { return }
    let arrives = reservations.map { $0.arrivalTime }
    let waits = arrives.map { NSDate().timeIntervalSinceDate($0)  }
    let average = (waits.reduce(0,combine: +) / Double(waits.count))
    averageWaitTime = Int(average/60)
}

func checkReservations() {
    DataHelper.requestReservations { reservations, error in
        self.reservations = reservations!
        self.reservations.sortInPlace {  $0.isReady && !$1.isReady  }
    }
}

func checkTableView() {
    tableView.reloadData()
}
```
This function provides the cells for the table view.  The reservations that are ready to seat have a green background to make them stand out from the other reservations.
``` swift
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! TableCell
    if indexPath.section == 0 {
        cell.backgroundColor = UIColor.grayColor()
        cell.name.text = "Name"
        cell.partySize.text = "Party Size"
        cell.timeArrived.text = "Time Arrived"
    } else {
        let reservation = reservations[indexPath.row]
        if reservation.isReady {
            cell.backgroundColor = UIColor.greenColor()
        } else {
            cell.backgroundColor = nil
        }
        cell.name.text = reservation.name
        cell.partySize.text = "\(reservation.size)"
        let time = NSDateFormatter.localizedStringFromDate(reservation.arrivalTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        cell.timeArrived.text = time
        
    }
    return cell
}
```

#### DataHelper
This class is a collection of static methods used to request information from our server and
process what is returned as well as send information to the server and process the response.

First we have the completionHandler, this creates a basic NSURLRequest to our server's web
address and then asynchronously processes the response.

``` swift
static func requestReservations(completionHandler: (reservations: [Reservation]?, error: ErrorType?) -> ()) {
        let nsURL = NSURL(string: baseUrl)
        let request = NSMutableURLRequest(URL: nsURL!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, res, err in
            if let responseData = data {
                let dict = processResponse(responseData)
                let reservations = processDict(dict)
                completionHandler(reservations: reservations, error: err)
            }
        }
        task.resume()
        
    }

```
this process response method takes in an NSData object and returns a dictionary 
with a integer key and array of strings as its value. These map to our Reservation
objects's ID as the key and its other variables as the array of strings.  It first
converts the data object into a string value with UTF-8 encoding and then 
splits that string on the new line. Since our data is stored in a CSV format
we can split each line into key value pairs by using the ',' as a split condition
now each value is then grabbed by splitting the the elements of this new array of strings
on the ':' caracter. In most situations this would create an array of 2 strings so we can rely on the 
value being in the second element of the array. The time syntax makes this more difficult
since there are multiple ':' characters, so here we drop the first value and interpolate
the remaining elements.


``` swift 
static func processResponse(data: NSData) -> [Int:[String]] {
        var reservations = [Int: [String]]()
        if let responseString = String(data: data, encoding: 8) {
            let lines = responseString.componentsSeparatedByString("\n")
            for line in lines {
                var id: Int?
                let splitLine = line.componentsSeparatedByString(",")
                for component in splitLine {
                    if component.containsString("id:") && !component.containsString("isReady") {
                        let idString = component.componentsSeparatedByString(":")[1]
                        id = Int(idString)
                        reservations[id!] = [String]()
                    } else if component.containsString("time") {
                        let timeArray = component.componentsSeparatedByString(":")
                        let time = "\(timeArray[1]):\(timeArray[2]):\(timeArray[3])"
                        reservations[id!]?.append(time)
                    } else if component.containsString(":") {
                        let element = component.componentsSeparatedByString(":")[1]
                        reservations[id!]?.append(element)
                    }
                }
            }
        }
        return reservations
    }

```
now that we have our elements in a dictionary format they are much closer to their swift
object definition.  the processDict function takes in our dictionary and 
loops over each element mapping our dictionary into our object constructor.
the challenge again here is with the date because string to date conversion
is pretty poorly supported in the Objective-C/Swift languages. 
However the NSDateFormatter did allow us to reliably convert our
formatting here, I have not experienced this being true of other
date sources.  

```
static func processDict(dict: [Int:[String]]) -> [Reservation] {
        var reservations = [Reservation]()
        for (key, value) in dict {
            let name = value[0]
            let size = Int(value[1])
            let stripedTime = value[2].componentsSeparatedByString(" ")
            let formatter = NSDateFormatter()
            let combinedTime = stripedTime[0] + " " + stripedTime[1]
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let ready = value[3] == "true"
            //the server calculates the time GMT, this corrects for that
            let arrivalTime = formatter.dateFromString(combinedTime)?.dateByAddingTimeInterval(-18000)
            
            
            let reservation = Reservation(id: key, name: name, size: size!, arrivalTime: arrivalTime!, isReady: ready)
            reservation.id = key
            reservations.append(reservation)
        }
        return reservations
    }
```

the remaining methods are essencially the same process with different inputs. Posting a new
reservation sends the reservation into to our server in an NSURLRequest and our server
returns the full list it is currently holding. We then process the response as we did initially.
Seating a reservation sends a PUT request and again processes the response in the same manner
and finally the delete request send the ID of the reservation and the server
replies with the newly shortened list. 

``` swift 
static func postReservation(name: String, partySize: Int, completionHandler: (reservations: [Reservation]?, error: ErrorType?) -> ()) {
        let urlString = baseUrl+"/\(name)/\(partySize)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, res, err in
            let dict = processResponse(data!)
            let reservations = processDict(dict)
            completionHandler(reservations: reservations, error: err)
        }
        task.resume()
    }
    
    static func seatReservation(id: Int, completionHandler: (reservations: [Reservation]?, error: ErrorType?) -> ()) {
        let urlString = baseUrl+"/seat/\(id)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, res, err in
            let dict = processResponse(data!)
            let reservations = processDict(dict)
            completionHandler(reservations: reservations, error: err)
        }
        task.resume()
    }
    
    static func removeReservation(id: Int, completionHandler: (reservations: [Reservation]?, error: ErrorType?) -> ()) {
        let urlString = baseUrl+"/remove/\(id)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, res, err in
            let dict = processResponse(data!)
            let reservations = processDict(dict)
            completionHandler(reservations: reservations, error: err)
        }
        task.resume()

    }

```
#### Reservation
A simple class to hold the reservation data.
``` swift
class Reservation {
    var id: Int?
    var name: String
    var size: Int
    var arrivalTime: NSDate
    var isReady: Bool
    
    init(name: String, size: Int, arrivalTime: NSDate = NSDate()) {
        self.name = name
        self.size = size
        self.arrivalTime = arrivalTime
        self.isReady = false
    }
    
    init(id: Int, name: String, size: Int, arrivalTime: NSDate, isReady: Bool) {
        self.id = id
        self.name = name
        self.size = size
        self.arrivalTime = arrivalTime
        self.isReady = isReady
    }
}
```

User Interface
--------------
##iOS


When a new reservation enters the resteraunt, the host
will enter his/her party name and the party size.
![adding a reservation](http://i.imgur.com/s4AcZRQ.png)


This now appears on the main screen along with 
the other reservations currently waiting.
![reservations waiting](http://i.imgur.com/wQ1ZFUT.png)

When a party is ready the host long-presses the name
and this reservations is now ready to be seated.
![reservations ready](http://i.imgur.com/z7NtlAu.png)


##tvOS

This will mirror the view of our iOS device. 
here we have the empty view.
![empty view](http://i.imgur.com/TDYm8gi.png)


When the host adds a new reservaton it will appear
along with the average amount of time all of the 
reservations have been waiting.
![new reservations](http://i.imgur.com/WsPgPdS.png)

When the host is ready to seat a party they also 
move to the top of the list and turn green
![ready to be seated](http://i.imgur.com/9KVB6Ay.png)

finally the party has been removed from the list.
![seated](http://i.imgur.com/PT0rlzd.png)
