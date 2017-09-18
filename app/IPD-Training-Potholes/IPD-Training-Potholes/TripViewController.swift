//
//  TripViewController.swift
//  IPD-Training-Potholes
//
//  Created by Shouvik Mani on 3/16/17.
//  Copyright © 2017 Shouvik Mani. All rights reserved.
//

import UIKit
import MessageUI

class TripViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var potholeButton: UIButton!
    @IBOutlet weak var numPotholesLabel: UILabel!
    
    var tripPotholes: TripPotholes!
    var numPotholes = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true  // Prevents sleep mode
        
        potholeButton.frame = CGRect(x: 80, y: 200, width: 100, height: 100)
        potholeButton.layer.borderColor = self.view.tintColor.cgColor
        potholeButton.backgroundColor = self.view.tintColor
        potholeButton.setTitleColor(UIColor.white, for: .normal)
        potholeButton.layer.borderWidth = 2
        potholeButton.layer.cornerRadius = 50
    }
    
    @IBAction func recordPothole(_ sender: Any) {
        incrementNumPotholes()
        recordPotholeData()
    }
    
    // Update number of potholes label on UI
    func incrementNumPotholes() {
        numPotholes += 1
        numPotholesLabel.text = String(numPotholes)
    }
    
    // Updates tripPotholes with pothole timestamp (in UNIX time)
    func recordPotholeData() {
        var current = NSDate().timeIntervalSince1970
        current = (current * 10).rounded() / 10  // Round to 2 decimal places
        tripPotholes.addPotholeTimestamp(timestamp: current)
    }

    // Sends trip data and passes to ViewController on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TripEndSegue" {
            sendTripData()
        }
    }
    
    // Sends trip data to recipient email
    func sendTripData() {
        let potholeFileName = tripPotholes.name + "_potholes.csv"
        let potholeDataPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(potholeFileName)
        var csvText = "timestamp\n"
        for timestamp in tripPotholes.potholeTimestamps {
            let newline = String(timestamp) + "\n"
            csvText.append(contentsOf: newline.characters)
        }
        do {
            try csvText.write(to: potholeDataPath!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        if MFMailComposeViewController.canSendMail() {
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self
            emailController.setToRecipients([])
            emailController.setSubject("Intelligent Pothole Detection Data - Potholes")
            emailController.setMessageBody("", isHTML: false)
            emailController.addAttachmentData(NSData(contentsOf: potholeDataPath!)! as Data, mimeType: "text/csv", fileName: potholeFileName)
            present(emailController, animated: true, completion: nil)
        }
        
    }
    
    // Dismisses mail view controller on Send or Cancel
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
