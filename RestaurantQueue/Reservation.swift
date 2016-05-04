//
//  Party.swift
//  RestaurantQueue
//
//  Created by Mason Elmore on 4/21/16.
//  Copyright © 2016 Swifty Swifters. All rights reserved.
//

import Foundation

class Reservation {
    var id: Int?
    var name: String
    var size: Int
    var arrivalTime: NSDate
    var isReady: Bool
    
    init(name: String, size: Int, arrivalTime: NSDate = NSDate()) {
        self.name = name
        self.size = size
        self.arrivalTime = arrivalTime
        self.isReady = false
    }
    
    init(id: Int, name: String, size: Int, arrivalTime: NSDate, isReady: Bool) {
        self.id = id
        self.name = name
        self.size = size
        self.arrivalTime = arrivalTime
        self.isReady = isReady
    }
}