//
//  ViewController.swift
//  RestaurantQueueTV
//
//  Created by Mason Elmore on 4/21/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import UIKit
import CoreBluetooth

class TVReservationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var avgWaitTimeLabel: UILabel!
    
    var cm: CBCentralManager!

    
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
        let secondDate = NSDate().dateByAddingTimeInterval(-8000.00)
        reservations.append(Reservation(name: "james", size: 5, arrivalTime: secondDate))
        let timer = NSTimer(timeInterval: 10.0, target: self, selector: #selector(calculateAverageWait), userInfo: nil, repeats: true)
        timer.fire()
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        cm = CBCentralManager(delegate: self, queue: nil)
        
        cm!.scanForPeripheralsWithServices(nil, options: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! TableCell
        if indexPath.section == 0 {
            cell.backgroundColor = UIColor.grayColor()
        } else {
            let reservation = reservations[indexPath.row]
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
    
    //btStuff
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
            switch central.state {
            case .PoweredOn:
                print("state is powered on")
                break
            case .PoweredOff:
                print("state is powered off")
                break
            case .Resetting:
                print("state is resetting")
                break
            case .Unauthorized:
                print("state is unauthorized")
                break
            case .Unknown:
                print("state is unknown")
                break
            case .Unsupported:
                print("state is unsupported")
                break
        }
        //guard central.state == .PoweredOn else { return }
        
        central.scanForPeripheralsWithServices(nil, options: nil)
        print("scanning: \(central.isScanning)")
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print(peripheral.name)
    }
    
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        central.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            for service in peripheral.services! {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for characteristic in service.characteristics! {
            print("service: \(service)")
            print("characteristic: \(characteristic)")
            print("value: \(peripheral.readValueForCharacteristic(characteristic))")
        }
    }
}