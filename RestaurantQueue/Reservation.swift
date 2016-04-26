//
//  Party.swift
//  RestaurantQueue
//
//  Created by Mason Elmore on 4/21/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import Foundation

// Reservation information neatly packaged inside of a structure.
struct Reservation: Equatable {
    var name: String
    var size: Int
    var arrivalTime: NSDate
    
    init(name: String, size: Int, arrivalTime: NSDate = NSDate()) {
        self.name = name
        self.size = size
        self.arrivalTime = arrivalTime
    }
}

func ==(lhs: Reservation, rhs: Reservation) -> Bool {
    return (lhs.name == rhs.name && lhs.size == rhs.size && lhs.arrivalTime == rhs.arrivalTime)
}
