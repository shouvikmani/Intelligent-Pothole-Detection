//
//  ViewController.swift
//  IPD-Training-Potholes
//
//  Created by Shouvik Mani on 3/16/17.
//  Copyright © 2017 Shouvik Mani. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tripNameField: UITextField!
    
    var tripPotholes: TripPotholes!

    override func viewDidLoad() {
        super.viewDidLoad()
        tripNameField.delegate = self
        tripNameField.borderStyle = .roundedRect;
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
            controller.tripPotholes = self.tripPotholes
        }
    }
    
    // Initializes a trip with the given name
    private func initializeTripWithName() {
        var tripName: String!
        tripName = tripNameField.text
        self.tripPotholes = TripPotholes.init(name: tripName)
    }

}
