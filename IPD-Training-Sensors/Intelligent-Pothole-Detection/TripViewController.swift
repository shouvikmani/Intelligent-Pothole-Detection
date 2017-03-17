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
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var accelerometerLabel: UILabel!
    @IBOutlet weak var gyroLabel: UILabel!
    
    var trip: TripSensors!
    var secondsElapsed = 0.0
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
        
        // Timer makes 5 calls per second to updateTime()
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
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
        secondsElapsed += 0.2
        let timeElapsedString = getTimeElapsedString()
        durationLabel.text = String(timeElapsedString)
        
        let currentSpeed = String(format: "%.2f m/s", (locationManager.location?.speed)!)
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
        let secondsElapsedInt = Int(secondsElapsed)
        var seconds = String(secondsElapsedInt % 60)
        if (seconds.characters.count == 1) {
            seconds = "0" + seconds
        }
        var minutes = String((secondsElapsedInt / 60) % 60)
        if (minutes.characters.count == 1) {
            minutes = "0" + minutes
        }
        var hours = String(secondsElapsedInt / 3600)
        if (hours.characters.count == 1) {
            hours = "0" + hours
        }
        let timeElapsedString = hours + ":" + minutes + ":" + seconds
        return timeElapsedString
    }
    
    // Updates trip object with sensor data (timestamp, lat/lon, 
    // speed, acceleration)
    func recordSensorData() {
        
        // Timestamp in UNIX time
        var current = NSDate().timeIntervalSince1970
        current = (current * 10).rounded() / 10  // Round to 2 decimal places
        trip.addSensorTimestamp(timestamp: current)
        
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
        let sensorFileName = trip.name + "_sensors.csv"
        let sensorDataPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(sensorFileName)
        var csvText = "timestamp,latitude,longitude,speed,accelerometerX,accelerometerY,accelerometerZ,gyroX,gyroY,gyroZ\n"
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
            emailController.setToRecipients([])
            emailController.setSubject("Intelligent Pothole Detection Data - Sensors")
            emailController.setMessageBody("", isHTML: false)
            emailController.addAttachmentData(NSData(contentsOf: sensorDataPath!)! as Data, mimeType: "text/csv", fileName: sensorFileName)
            present(emailController, animated: true, completion: nil)
        }

    }
    
    // Dismisses mail view controller on Send or Cancel
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
