//
//  PassReservationBackToPreviousViewControllerDelegateProtocol.swift
//  RestaurantQueue
//
//  Created by Mason Elmore on 4/22/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import Foundation

// This is used to passing back the reservation information back to the previous view controller 😉
protocol passReservationBackToPreviousViewControllerDelegate {
    func passReservationBackToPreviousViewController(reservation: Reservation)
    func reservationAddedNotification(name: String, size: Int)
}
