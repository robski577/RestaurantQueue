//
//  ViewController.swift
//  RestaurantQueue
//
//  Created by Mason Elmore on 4/21/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import UIKit

class ReservationListViewController: UIViewController {
    
    @IBOutlet weak var reservationTableView: UITableView!
    
    // All reservations in one array.  Use computed fields to get ready and waiting reservation arrays.
    // TODO: Decide if using two separate arrays would be easier to read/maintain.
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
    
    let readySectionIndex = 0
    let waitingSectionIndex = 1

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

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        retrieveReservations()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
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

}


extension ReservationListViewController: UITableViewDataSource {
    
    func checkReservations() {
        if reservationTableView.numberOfRowsInSection(readySectionIndex) == readyReservations.count &&
            reservationTableView.numberOfRowsInSection(waitingSectionIndex) == waitingReservations.count {
            return
        }
        reservationTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == readySectionIndex {
            return readyReservations.count
        } else {
            return waitingReservations.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == readySectionIndex {
            return "Ready"
        } else {
            return "Waiting"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = reservationTableView.dequeueReusableCellWithIdentifier("Reservation Cell", forIndexPath: indexPath) as! ReservationCell
        
        // Fetch the reservation from the respective section
        var reservation: Reservation
        if indexPath.section == readySectionIndex {
            reservation = readyReservations[indexPath.row]
            cell.backgroundColor = UIColor.greenColor()
        } else {
            reservation = waitingReservations[indexPath.row]
            cell.backgroundColor = nil
        }
        
        // Dump the reservation information into the cell
        cell.nameLabel.text = reservation.name
        cell.partySizeLabel.text = String(reservation.size)
        let displayTime =  NSDateFormatter.localizedStringFromDate(reservation.arrivalTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        cell.arrivalTime.text = String(displayTime)
        
        return cell
    }
    
}

extension ReservationListViewController: UIGestureRecognizerDelegate {
    
    func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .Ended) {
            return
        }
        
        let p = gestureRecognizer.locationInView(self.reservationTableView)
        if let indexPath = self.reservationTableView.indexPathForRowAtPoint(p) {
            let reservation = reservations[indexPath.row]
            // Remove the reservation if it is ready.  Move to ready if it is waiting.
            if reservation.isReady {
                sendRemovalRequest(reservation.id!)
            } else {
                sendSeatRequest(reservation.id!)
            }
        }
    }
}

extension ReservationListViewController: passReservationBackToPreviousViewControllerDelegate {
    
    func addReservation(name: String, size: Int) {
        DataHelper.postReservation(name, partySize: size) { reservations, error in
            if error == nil {
                self.reservations = reservations!
            }
        }
    }
    
    func passReservationBackToPreviousViewController(reservation: Reservation) {
    }
    
    func reservationAddedNotification(name: String, size: Int) {
        addReservation(name, size: size)
    }
}