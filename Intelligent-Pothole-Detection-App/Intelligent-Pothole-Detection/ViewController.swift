//
//  ViewController.swift
//  Intelligent-Pothole-Detection
//
//  Created by Shouvik Mani on 2/20/17.
//  Copyright © 2017 Shouvik Mani. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tripNameField: UITextField!
    
    var trip: Trip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripNameField.delegate = self
        tripNameField.borderStyle = .roundedRect;
        loadMap()
    }

    func loadMap() {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // Passes trip object to TripViewController on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TripStartSegue" {
            self.initializeTripWithName()
            let controller = segue.destination as! TripViewController
            controller.trip = self.trip
        }
    }
    
    // Initializes a trip with the given name
    private func initializeTripWithName() {
        var tripName: String!
        tripName = tripNameField.text
        self.trip = Trip.init(name: tripName)
    }
    
}
