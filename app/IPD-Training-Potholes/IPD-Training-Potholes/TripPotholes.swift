//
//  TripPotholes.swift
//  IPD-Training-Potholes
//
//  Created by Shouvik Mani on 3/16/17.
//  Copyright © 2017 Shouvik Mani. All rights reserved.
//

import Foundation

class TripPotholes {
    
    var name: String
    var potholeTimestamps = [Double]()
    
    init(name: String) {
        self.name = name
    }
    
    func getPotholeTimestamps() -> [Double] {
        return potholeTimestamps
    }
    
    func addPotholeTimestamp(timestamp: Double) {
        potholeTimestamps.append(timestamp)
    }

}
