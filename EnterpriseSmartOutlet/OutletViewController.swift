//
//  OutletViewController.swift
//  EnterpriseSmartOutlet
//
//  Created by Riley McGovern on 3/1/15.
//  Copyright (c) 2015 Riley McGovern. All rights reserved.
//

import UIKit
import RealmSwift

class OutletViewController: UIViewController {
    
    var outlet: Outlet?
    var ipAddress: String?

    @IBOutlet weak var voltageLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var inUseLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let newOutlet = outlet {
            voltageLabel.text = String(format: "%.2f", newOutlet.voltage)
            currentLabel.text = String(format: "%.2f", newOutlet.current)
            powerLabel.text = String(format: "%.2f", newOutlet.voltage * newOutlet.current)
            locationLabel.text = newOutlet.details
            inUseLabel.text = "\(newOutlet.current >= 0.001)"
            if newOutlet.current >= 0.001 {
                statusLabel.text = "Status: In Use"
                statusImage.image = UIImage(named: "InUse")
            }
            else {
                statusLabel.text = "Status: Free"
                statusImage.image = UIImage(named: "Free")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleButtonPressed(sender: AnyObject) {
        if let newOutlet = outlet {
//            let requestString = outlet?.id
//            if let ip = self.ipAddress {
//                let url = NSURL(string: ip)
//                var session = NSURLSession.sharedSession()
//                let request = NSMutableURLRequest(URL: url!)
//                request.HTTPMethod = "POST"
//            }
            let alert = UIAlertController(title: newOutlet.name + " Toggled", message: newOutlet.name + " has been toggled on/off.", preferredStyle: UIAlertControllerStyle.Alert)
            let okay = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(okay)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
