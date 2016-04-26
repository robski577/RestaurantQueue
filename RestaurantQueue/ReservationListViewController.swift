//
//  ViewController.swift
//  RestaurantQueue
//
//  Created by Mason Elmore on 4/21/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import UIKit
import CoreBluetooth

class ReservationListViewController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var reservationTableView: UITableView!
    
    var reservations = [Reservation]()
    
    let reservationListUUID = CBUUID(string: "0c8717e8-99d9-4dac-937f-b3400922befb")
    let addUUID = CBUUID(string: "71d7d259-ed52-4bed-b7c8-a76b9c931a66")
    let removeUUID = CBUUID(string: "a9e28957-e093-4dc6-bdcf-b26363877655")
    var reservationService: CBMutableService!
    var addCharacteristic: CBMutableCharacteristic!
    var removeCharacteristic: CBMutableCharacteristic!
    
    var pm: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate for passing back reservation information
        AddReservationViewController.delegate = self
        pm = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func testing() {
        let one = Reservation(name: "robert", size: 2)
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let date = NSDate().dateByAddingTimeInterval(-500.00)
        let two = Reservation(name: "steve", size: 3, arrivalTime: date)
        let secondDate = NSDate().dateByAddingTimeInterval(-8000.00)
        let three = Reservation(name: "james", size: 5, arrivalTime: secondDate)
        self.addReservation(one)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addReservation(reservation: Reservation) {
        reservations.append(reservation)
        reservationTableView.reloadData()
        
        // TODO: Send reservation to TV
        pm.startAdvertising(["newReservation": "isWaiting"])
    }
    
    func removeReservation(reservation: Reservation) {
        reservations = reservations.filter { $0 != reservation }
        reservationTableView.reloadData()
        pm.startAdvertising(["removeReservation": "isWaiting"])
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("state as peripheral")
        printStateAsString(peripheral.state.rawValue)

        reservationService = CBMutableService(type: reservationListUUID, primary: true)
        addCharacteristic = CBMutableCharacteristic(type: addUUID, properties: CBCharacteristicProperties.Read, value: nil, permissions: CBAttributePermissions.Readable)
        removeCharacteristic = CBMutableCharacteristic(type: removeUUID, properties: CBCharacteristicProperties.Read, value: nil, permissions: CBAttributePermissions.Readable)
        reservationService.characteristics?.append(addCharacteristic)
        reservationService.characteristics?.append(removeCharacteristic)
        peripheral.addService(reservationService)
        peripheral.startAdvertising(["hostSTand":"forConnection"])
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print(request)
    }
    
    
    func printStateAsString(state: Int) {
        switch state {
            case 5:
                print("state is powered on")
                break
            case 4:
                print("state is powered off")
                break
            case 1:
                print("state is resetting")
                break
            case 3:
                print("state is unauthorized")
                break
            case 0:
                print("state is unknown")
                break
            case 2:
                print("state is unsupported")
                break
            default:
                print("state is unknown")
            break
        }
    }
}


extension ReservationListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = reservationTableView.dequeueReusableCellWithIdentifier("Reservation Cell", forIndexPath: indexPath) as! ReservationCell
        cell.nameLabel.text = reservations[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    
}


extension ReservationListViewController: passReservationBackToPreviousViewControllerDelegate {
    
    func passReservationBackToPreviousViewController(reservation: Reservation) {
        addReservation(reservation)
    }
    
}