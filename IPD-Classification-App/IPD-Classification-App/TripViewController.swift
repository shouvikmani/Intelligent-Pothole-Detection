//
//  TripViewController.swift
//  IPD-Classification-App
//
//  Created by Shouvik Mani on 5/8/17.
//  Copyright © 2017 Shouvik Mani. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreMotion
import AVFoundation
import MessageUI

class TripViewController: UIViewController, MKMapViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var roadConditionLabel: UILabel!
    @IBOutlet weak var potholeImage: UIImageView!

    var tripData: [[String: Double]] = []
    var intervalRoadConditions = IntervalsRoadConditions()
    var intervalPotholes = IntervalsPotholes()
    var locationManager: CLLocationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    let potholeSound: SystemSoundID = 1005
    var recordSensorDataTimer: Timer = Timer()
    var classifyPotholeTimer: Timer = Timer()
    var classifyRoadConditionsTimer: Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true  // Prevents sleep mode
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        
        loadMap()
        
        // Timer makes 5 calls per second to recordSensorData()
        recordSensorDataTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(recordSensorData), userInfo: nil, repeats: true)
        classifyPotholeTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(classifyPothole), userInfo: nil, repeats: true)
        classifyRoadConditionsTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(classifyRoadConditions), userInfo: nil, repeats: true)
    }
    
    func loadMap() {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    func recordSensorData() {
        var tripDataPoint = [String: Double]()
        
        // Timestamp in UNIX time
        var current = NSDate().timeIntervalSince1970
        current = (current * 10).rounded() / 10  // Round to 2 decimal places
        tripDataPoint["timestamp"] = current
        
        let currentSpeed = (locationManager.location?.speed)!
        tripDataPoint["speed"] = currentSpeed
        
        let acceleration = motionManager.accelerometerData?.acceleration
        if acceleration != nil {
            tripDataPoint["accelerometerX"] = acceleration!.x
            tripDataPoint["accelerometerY"] = acceleration!.y
            tripDataPoint["accelerometerZ"] = acceleration!.z
        } else {
            tripDataPoint["accelerometerX"] = -100.0
            tripDataPoint["accelerometerY"] = -100.0
            tripDataPoint["accelerometerZ"] = -100.0
        }
        
        let gyro = motionManager.gyroData?.rotationRate
        if gyro != nil {
            tripDataPoint["gyroX"] = gyro!.x
            tripDataPoint["gyroY"] = gyro!.y
            tripDataPoint["gyroZ"] = gyro!.z
        } else {
            tripDataPoint["gyroX"] = -100.0
            tripDataPoint["gyroY"] = -100.0
            tripDataPoint["gyroZ"] = -100.0
        }
        
        let latlong = (locationManager.location?.coordinate)
        tripDataPoint["latitude"] = (latlong?.latitude)!
        tripDataPoint["longitude"] = (latlong?.longitude)!
        
        tripData.append(tripDataPoint)
    }
    
    func classifyRoadConditions() {
        let intervalData = getIntervalJSON(intervalLength: 5)
        let intervalJSONString = intervalData.intervalJSONString
        let intervalLatitudes = intervalData.intervalLatitudes
        let intervalLongitudes = intervalData.intervalLongitudes
        
        let url = URL(string: "https://ipd-classification-server.herokuapp.com/classifyRoadConditions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let postString = "sensorData=" + intervalJSONString
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                let prediction = String(data: data!, encoding: String.Encoding.utf8)!
                DispatchQueue.main.async {
                    if (Double(prediction) == 0) {
                        self.roadConditionLabel.text = "Good"
                        self.roadConditionLabel.textColor = UIColor(red: 0/255, green: 200/255, blue: 100/255, alpha: 1)
                    } else {
                        self.roadConditionLabel.text = "Bad"
                        self.roadConditionLabel.textColor = UIColor.red
                    }
                }
                let index = self.intervalPotholes.numIntervals
                for i in 0..<intervalLatitudes.count {
                    self.intervalRoadConditions.interval.append(index)
                    self.intervalRoadConditions.latitude.append(intervalLatitudes[i])
                    self.intervalRoadConditions.longitude.append(intervalLongitudes[i])
                    self.intervalRoadConditions.classification.append(Double(prediction)!)
                }
                self.intervalRoadConditions.numIntervals = index + 1
            }
        }
        task.resume()
    }
    
    func classifyPothole() {
        let intervalData = getIntervalJSON(intervalLength: 2)
        let intervalJSONString = intervalData.intervalJSONString
        let intervalLastLatitude = intervalData.intervalLatitudes.last!
        let intervalLastLongitude = intervalData.intervalLongitudes.last!
        
        let url = URL(string: "https://ipd-classification-server.herokuapp.com/classifyPotholes")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let postString = "sensorData=" + intervalJSONString
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error == nil {
                let prediction = String(data: data!, encoding: String.Encoding.utf8)!
                DispatchQueue.main.async {
                    if (Double(prediction) == 0) {
                        self.potholeImage.image = UIImage(named: "Non-Pothole")
                    } else {
                        AudioServicesPlaySystemSound(self.potholeSound)
                        self.potholeImage.image = UIImage(named: "Pothole")
                    }
                }
                let index = self.intervalPotholes.numIntervals
                self.intervalPotholes.interval.append(index)
                self.intervalPotholes.latitude.append(intervalLastLatitude)
                self.intervalPotholes.longitude.append(intervalLastLongitude)
                self.intervalPotholes.classification.append(Double(prediction)!)
                self.intervalPotholes.numIntervals = index + 1
            }
        }
        task.resume()
    }
    
    func getIntervalJSON(intervalLength: Int) -> (intervalJSONString: String,
        intervalLatitudes: [Double], intervalLongitudes: [Double]) {
        let numPointsInInterval = 5 * intervalLength
        let interval = tripData.suffix(numPointsInInterval)
        let intervalLatitudes = getLatLngArray(intervalData: Array(interval), type: "latitude")
        let intervalLongitudes = getLatLngArray(intervalData: Array(interval), type: "longitude")
        let s1 = interval.description
        let s2 = s1.replacingOccurrences(of: "[", with: "{")
        let s3 = s2.replacingOccurrences(of: "]", with: "}")
        let s4 = "[" + String(s3.characters.dropFirst())
        let s5 = String(s4.characters.dropLast()) + "]"
        return (s5, intervalLatitudes, intervalLongitudes)
    }
    
    func getLatLngArray(intervalData: [[String: Double]], type: String) -> [Double] {
        var values = [Double]()
        for point in intervalData {
            let value = point[type]
            values.append(value!)
        }
        return (values)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TripEndSegue" {
            recordSensorDataTimer.invalidate()
            classifyPotholeTimer.invalidate()
            classifyRoadConditionsTimer.invalidate()
            sendTripData()
        }
    }
    
    // Sends trip data to recipient email
    func sendTripData() {
        let roadConditionsFileName = "roadConditionsIntervals.csv"
        let roadCondtisionsFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(roadConditionsFileName)
        var csvText = "interval, latitude, longitude, classification\n"
        for i in 0..<intervalRoadConditions.interval.count {
            let interval = intervalRoadConditions.interval[i]
            let latitude = intervalRoadConditions.latitude[i]
            let longitude = intervalRoadConditions.longitude[i]
            let classification = intervalRoadConditions.classification[i]
            let newline = String(interval) + "," + String(latitude) + "," + String(longitude) + "," + String(classification) + "\n"
            csvText.append(contentsOf: newline.characters)
        }
        do {
            try csvText.write(to: roadCondtisionsFilePath!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }

        let potholesFileName = "potholesIntervals.csv"
        let potholesFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(potholesFileName)
        csvText = "interval, latitude, longitude, classification\n"
        for i in 0..<intervalPotholes.interval.count {
            let interval = intervalPotholes.interval[i]
            let latitude = intervalPotholes.latitude[i]
            let longitude = intervalPotholes.longitude[i]
            let classification = intervalPotholes.classification[i]
            let newline = String(interval) + "," + String(latitude) + "," + String(longitude) + "," + String(classification) + "\n"
            csvText.append(contentsOf: newline.characters)
        }
        do {
            try csvText.write(to: potholesFilePath!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        
        if MFMailComposeViewController.canSendMail() {
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self
            emailController.setToRecipients([])
            emailController.setSubject("Intelligent Pothole Detection - Classification")
            emailController.setMessageBody("", isHTML: false)
            emailController.addAttachmentData(NSData(contentsOf: roadCondtisionsFilePath!)! as Data, mimeType: "text/csv", fileName: roadConditionsFileName)
            emailController.addAttachmentData(NSData(contentsOf: potholesFilePath!)! as Data, mimeType: "text/csv", fileName: potholesFileName)
            present(emailController, animated: true, completion: nil)
        }
        
    }
    
    // Dismisses mail view controller on Send or Cancel
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
