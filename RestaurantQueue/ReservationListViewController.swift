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
        switch peripheral.state {
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