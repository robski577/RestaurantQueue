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
        reservations.append(Reservation(name: "robert", size: 2))
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let date = NSDate().dateByAddingTimeInterval(-500.00)
        reservations.append(Reservation(name: "steve", size: 3, arrivalTime: date))
        let secondDate = NSDate().dateByAddingTimeInterval(-800.00)
        reservations.append(Reservation(name: "james", size: 5, arrivalTime: secondDate))
        let timer = NSTimer(timeInterval: 10.0, target: self, selector: #selector(calculateAverageWait), userInfo: nil, repeats: true)
        timer.fire()
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! TableCell
        
        let reservation = reservations[indexPath.row]
        cell.name.text = reservation.name
        cell.partySize.text = "\(reservation.size)"
        let time = NSDateFormatter.localizedStringFromDate(reservation.arrivalTime, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        cell.timeArrived.text = time
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }

    
    func calculateAverageWait() {
        let arrives = reservations.map { $0.arrivalTime }
        let waits = arrives.map { NSDate().timeIntervalSinceDate($0)  }
        let average = (waits.reduce(0,combine: +) / Double(waits.count))
        averageWaitTime = Int(average/60)
    }
}

