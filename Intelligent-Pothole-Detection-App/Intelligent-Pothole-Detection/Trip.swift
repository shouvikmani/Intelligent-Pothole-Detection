//
//  Trip.swift
//  Intelligent-Pothole-Detection
//
//  Created by Shouvik Mani on 2/20/17.
//  Copyright © 2017 Shouvik Mani. All rights reserved.
//

import Foundation

class Trip {
    
    var name: String
    var potholeTimestamps = [Int]()
    var sensorTimestamps = [Int]()
    var speeds = [Double]()
    var accelerationsX = [Double]()
    var accelerationsY = [Double]()
    var accelerationsZ = [Double]()
    var latitudes = [Double]()
    var longitudes = [Double]()
    
    init(name: String) {
        self.name = name
    }
    
    func getPotholeTimestamps() -> [Int] {
        return potholeTimestamps
    }
    
    func addPotholeTimestamp(timestamp: Int) {
        potholeTimestamps.append(timestamp)
    }
    
    func getSensorTimestamps() -> [Int] {
        return sensorTimestamps
    }
    
    func addSensorTimestamp(timestamp: Int) {
        sensorTimestamps.append(timestamp)
    }
    
    func getSpeeds() -> [Double] {
        return speeds
    }
    
    func addSpeed(speed: Double) {
        speeds.append(speed)
    }
    
    func addAccelerationX(accelX: Double) {
        accelerationsX.append(accelX)
    }
    
    func addAccelerationY(accelY: Double) {
        accelerationsY.append(accelY)
    }
    
    func addAccelerationZ(accelZ: Double) {
        accelerationsZ.append(accelZ)
    }
    
    func addLatitude(lat: Double) {
        latitudes.append(lat)
    }
    
    func addLongitude(long: Double) {
        longitudes.append(long)
    }
    
}
