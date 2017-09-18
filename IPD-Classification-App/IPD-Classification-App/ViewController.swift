//
//  ViewController.swift
//  IPD-Classification-App
//
//  Created by Shouvik Mani on 5/8/17.
//  Copyright © 2017 Shouvik Mani. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        loadMap()
        activityIndicator.hidesWhenStopped = true
    }
    
    func loadMap() {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    @IBAction func start(_ sender: Any) {
        startButton.isHidden = true
        activityIndicator.startAnimating()
        let url = URL(string: "https://ipd-classification-server.herokuapp.com/")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "TripStartSegue", sender: self)
                }
            }
        }
        task.resume()
    }
    
}
