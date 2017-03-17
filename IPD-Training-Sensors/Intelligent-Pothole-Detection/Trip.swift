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
    var potholeTimestamps = [Double]()
    var sensorTimestamps = [Double]()
    var speeds = [Double]()
    var accelerationsX = [Double]()
    var accelerationsY = [Double]()
    var accelerationsZ = [Double]()
    var gyrosX = [Double]()
    var gyrosY = [Double]()
    var gyrosZ = [Double]()
    var latitudes = [Double]()
    var longitudes = [Double]()
    
    init(name: String) {
        self.name = name
    }
    
    func getPotholeTimestamps() -> [Double] {
        return potholeTimestamps
    }
    
    func addPotholeTimestamp(timestamp: Double) {
        potholeTimestamps.append(timestamp)
    }
    
    func getSensorTimestamps() -> [Double] {
        return sensorTimestamps
    }
    
    func addSensorTimestamp(timestamp: Double) {
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
    
    func addGyroX(gyroX: Double) {
        gyrosX.append(gyroX)
    }
    
    func addGyroY(gyroY: Double) {
        gyrosY.append(gyroY)
    }
    
    func addGyroZ(gyroZ: Double) {
        gyrosZ.append(gyroZ)
    }
    
    func addLatitude(lat: Double) {
        latitudes.append(lat)
    }
    
    func addLongitude(long: Double) {
        longitudes.append(long)
    }
    
}
