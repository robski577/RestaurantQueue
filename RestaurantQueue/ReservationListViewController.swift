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
    var reservations: [Reservation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate for passing back reservation information
        AddReservationViewController.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        longPress.delaysTouchesBegan = true
        self.reservationTableView.addGestureRecognizer(longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addReservation(reservation: Reservation) {
        reservations.append(reservation)
        reservationTableView.reloadData()
        
        // TODO: Send reservation to TV
    }

}


extension ReservationListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = reservationTableView.dequeueReusableCellWithIdentifier("Reservation Cell", forIndexPath: indexPath) as! ReservationCell
        cell.nameLabel.text = reservations[indexPath.row].name
        cell.partySizeLabel.text = String(reservations[indexPath.row].size)
        let displayTime =  NSDateFormatter.localizedStringFromDate(reservations[indexPath.row].arrivalTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        cell.arrivalTime.text = String(displayTime)
        
        // Highlight ready reservations
        if reservations[indexPath.row].isReady {
            cell.backgroundColor = UIColor.greenColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Ready"
        } else {
            return "Waiting"
        }
    }
    
}

extension ReservationListViewController: UIGestureRecognizerDelegate {
    
    func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .Ended) {
            return
        }
        
        let p = gestureRecognizer.locationInView(self.reservationTableView)
        
        if let indexPath = self.reservationTableView.indexPathForRowAtPoint(p) {
            reservations[indexPath.row].isReady = true
        }
    }
    
}

extension ReservationListViewController: passReservationBackToPreviousViewControllerDelegate {
    
    func passReservationBackToPreviousViewController(reservation: Reservation) {
        addReservation(reservation)
    }
    
}