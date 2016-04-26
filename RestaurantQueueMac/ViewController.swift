//
//  ViewController.swift
//  RestaurantQueueMac
//
//  Created by Robert Masen on 4/25/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, CBPeripheralDelegate, CBCentralManagerDelegate {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var AvgWaitTime: NSTextField!
    
    var reservations = [Reservation]()
    var cm: CBCentralManager!
    var averageWaitTime = 0 {
        didSet {
            AvgWaitTime.stringValue = "\(averageWaitTime) Minutes"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return reservations.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let reservation = reservations[row]
        
        var title: String = ""
        var cellId: String = ""
        
        switch tableColumn! {
            case tableView.tableColumns[0]:
                title = reservation.name
                cellId = "name"
                break
            case tableView.tableColumns[1]:
                title = "\(reservation.size)"
                cellId = "size"
                break
            case tableView.tableColumns[2]:
                title = "\(NSDateFormatter.localizedStringFromDate(reservation.arrivalTime, dateStyle: .NoStyle, timeStyle: .ShortStyle))"
                cellId = "arrivaltime"
                break
            default:
            return nil
        }
        
        
        
        if let cell = tableView.makeViewWithIdentifier(cellId, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = title
            return cell
        }
        return nil
    }
    

    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NSTableRowView()
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

