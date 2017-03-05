//
//  TripViewController.swift
//  Intelligent-Pothole-Detection
//
//  Created by Shouvik Mani on 2/21/17.
//  Copyright © 2017 Shouvik Mani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
import MessageUI

class TripViewController: UIViewController, MKMapViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var numPotholesLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var accelerometerLabel: UILabel!
    @IBOutlet weak var gyroLabel: UILabel!
    
    var trip: Trip!
    var dataRecipientEmail: String!
    var secondsElapsed = 0
    var numPotholes = 0
    var locationManager: CLLocationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true  // Prevents sleep mode
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        
        loadMap()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func loadMap() {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    func updateTime() {
        updateDataLabels()
        recordSensorData()
    }
    
    // Update trip duration, speed, accelerometer, and gyro labels on UI
    func updateDataLabels() {
        secondsElapsed += 1
        let timeElapsedString = getTimeElapsedString()
        durationLabel.text = String(timeElapsedString)
        
        let currentSpeed = String(format: "%.2f m/s",
            (locationManager.location?.speed)!)
        speedLabel.text = currentSpeed
        
        let acceleration = motionManager.accelerometerData?.acceleration
        if acceleration != nil {
            let accelerometerString = String(format: "%.2f", acceleration!.x) + ", " +
                String(format: "%.2f", acceleration!.y) + ", " +
                String(format: "%.2f", acceleration!.z)
            accelerometerLabel.text = accelerometerString
        }
        
        let gyro = motionManager.gyroData?.rotationRate
        if gyro != nil {
            let gyroString = String(format: "%.2f", gyro!.x) + ", " + String(format: "%.2f", gyro!.y) + ", " + String(format: "%.2f", gyro!.z)
            gyroLabel.text = gyroString
        }
    }

    func getTimeElapsedString() -> String {
        var seconds = String(secondsElapsed % 60)
        if (seconds.characters.count == 1) {
            seconds = "0" + seconds
        }
        var minutes = String((secondsElapsed / 60) % 60)
        if (minutes.characters.count == 1) {
            minutes = "0" + minutes
        }
        var hours = String(secondsElapsed / 3600)
        if (hours.characters.count == 1) {
            hours = "0" + hours
        }
        let timeElapsedString = hours + ":" + minutes + ":" + seconds
        return timeElapsedString
    }
    
    @IBAction func recordPotholeAndIncrementNumPotholes(_ sender: Any) {
        incrementNumPotholes()
        recordPotholeData()
    }
    
    // Update number of potholes label on UI
    func incrementNumPotholes() {
        numPotholes += 1
        numPotholesLabel.text = String(numPotholes)
    }
    
    // Updates trip object with pothole timestamp (in UNIX time)
    func recordPotholeData() {
        let current = NSDate().timeIntervalSince1970
        trip.addPotholeTimestamp(timestamp: Int(current))
    }
    
    // Updates trip object with sensor data (timestamp, lat/lon, 
    // speed, acceleration)
    func recordSensorData() {
        
        // Timestamp in UNIX time
        let current = NSDate().timeIntervalSince1970
        trip.addSensorTimestamp(timestamp: Int(current))
        
        let currentSpeed = (locationManager.location?.speed)!
        trip.addSpeed(speed: currentSpeed)
        
        let acceleration = motionManager.accelerometerData?.acceleration
        if acceleration != nil {
            trip.addAccelerationX(accelX: acceleration!.x)
            trip.addAccelerationY(accelY: acceleration!.y)
            trip.addAccelerationZ(accelZ: acceleration!.z)
        } else {
            trip.addAccelerationX(accelX: -100.0)
            trip.addAccelerationY(accelY: -100.0)
            trip.addAccelerationZ(accelZ: -100.0)
        }
        
        let gyro = motionManager.gyroData?.rotationRate
        if gyro != nil {
            trip.addGyroX(gyroX: gyro!.x)
            trip.addGyroY(gyroY: gyro!.y)
            trip.addGyroZ(gyroZ: gyro!.z)
        } else {
            trip.addGyroX(gyroX: -100.0)
            trip.addGyroY(gyroY: -100.0)
            trip.addGyroZ(gyroZ: -100.0)
        }
        
        let latlong = (locationManager.location?.coordinate)
        trip.addLatitude(lat: (latlong?.latitude)!)
        trip.addLongitude(long: (latlong?.longitude)!)
    }
    
    // Sends trip data and passes to ViewController on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TripEndSegue" {
            sendTripData()
        }
    }
    
    // Sends trip data to recipient email
    func sendTripData() {
        let potholeFileName = trip.name + "_potholes.csv"
        let potholeDataPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(potholeFileName)
        var csvText = "timestamp\n"
        for timestamp in trip.potholeTimestamps {
            let newline = String(timestamp) + "\n"
            csvText.append(contentsOf: newline.characters)
        }
        do {
            try csvText.write(to: potholeDataPath!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        let sensorFileName = trip.name + "_sensors.csv"
        let sensorDataPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(sensorFileName)
        csvText = "timestamp,latitude,longitude,speed,accelerometerX,accelerometerY,accelerometerZ,gyroX,gyroY,gyroZ\n"
        for i in 0..<trip.sensorTimestamps.count {
            let timestamp = trip.sensorTimestamps[i]
            let latitude = trip.latitudes[i]
            let longitude = trip.longitudes[i]
            let speed = trip.speeds[i]
            let accelerometerX = trip.accelerationsX[i]
            let accelerometerY = trip.accelerationsY[i]
            let accelerometerZ = trip.accelerationsZ[i]
            let gyroX = trip.gyrosX[i]
            let gyroY = trip.gyrosY[i]
            let gyroZ = trip.gyrosZ[i]
            let newline = String(timestamp) + "," + String(latitude) + "," + String(longitude) + "," + String(speed) + "," + String(accelerometerX) + "," + String(accelerometerY) + "," + String(accelerometerZ) + "," + String(gyroX) + "," + String(gyroY) + "," + String(gyroZ) + "\n"
            csvText.append(contentsOf: newline.characters)
        }
        do {
            try csvText.write(to: sensorDataPath!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        if MFMailComposeViewController.canSendMail() {
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self
            emailController.setToRecipients([dataRecipientEmail])
            emailController.setSubject("Intelligent Pothole Detection Data")
            emailController.setMessageBody("", isHTML: false)
            emailController.addAttachmentData(NSData(contentsOf: potholeDataPath!)! as Data, mimeType: "text/csv", fileName: potholeFileName)
            emailController.addAttachmentData(NSData(contentsOf: sensorDataPath!)! as Data, mimeType: "text/csv", fileName: sensorFileName)
            present(emailController, animated: true, completion: nil)
        }

    }
    
    // Dismisses mail view controller on Send or Cancel
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
