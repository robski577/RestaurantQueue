//
//  ViewController.swift
//  RestaurantQueueTV
//
//  Created by Mason Elmore on 4/21/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import UIKit

class TVReservationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var avgWaitTimeLabel: UILabel!
    
    var reservations = [Reservation]()

    var averageWaitTime = 0 {
        didSet {
            avgWaitTimeLabel.text = "\(averageWaitTime) minutes"
        }
    }
    

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section ==  0 {
            return 1
        } else {
            return reservations.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    
    func calculateAverageWait() {
        guard reservations.count > 0 else { return }
        let arrives = reservations.map { $0.arrivalTime }
        let waits = arrives.map { NSDate().timeIntervalSinceDate($0)  }
        let average = (waits.reduce(0,combine: +) / Double(waits.count))
        averageWaitTime = Int(average/60)
    }
}

