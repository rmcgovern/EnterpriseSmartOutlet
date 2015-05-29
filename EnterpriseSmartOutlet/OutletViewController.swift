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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var lastContactLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let newOutlet = outlet {
            voltageLabel.text = String(format: "%.2f", newOutlet.voltage)
            currentLabel.text = String(format: "%.2f", newOutlet.current)
            powerLabel.text = String(format: "%.2f", newOutlet.voltage * newOutlet.current)
            descriptionLabel.text = newOutlet.details
            groupLabel.text = newOutlet.group
            lastContactLabel.text = newOutlet.lastContact
            
            setStatus(newOutlet)
        }
    }
    
    func setStatus(newOutlet: Outlet) {
        if newOutlet.current >= 0.001 {
            statusLabel.text = "Status: In Use"
            statusImage.image = UIImage(named: "InUse")
        }
        else {
            statusLabel.text = "Status: Free"
            statusImage.image = UIImage(named: "Free")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleButtonPressed(sender: AnyObject) {
        if let newOutlet = outlet,
               newIP     = ipAddress {
            var url: NSURL?
                
            if newOutlet.active {
                url = NSURL(string: "http://" + newIP + ":1337/?deactivate=" + newOutlet.macAddress)
                outlet!.active = false
                statusLabel.text = "Status: Inactive"
                statusImage.image = UIImage(named: "Inactive")
            }
            else {
                url = NSURL(string: "http://" + newIP + ":1337/?activate=" + newOutlet.macAddress)
                outlet!.active = true
                setStatus(newOutlet)
            }
            
            if url != nil {
                let urlRequest = NSURLRequest(URL: url!)
                NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {(resp: NSURLResponse!, data: NSData!, error: NSError!) -> Void in })
//                let alert = UIAlertController(title: newOutlet.name + " Toggled", message: newOutlet.name + " has been toggled on/off.", preferredStyle: UIAlertControllerStyle.Alert)
//                let okay = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
//                alert.addAction(okay)
//                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            else {
                let alert = UIAlertController(title: "Problem Forming Server URL", message: "There has been a problem toggling the outlet.", preferredStyle: UIAlertControllerStyle.Alert)
                let okay = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(okay)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
//            let alert = UIAlertController(title: newOutlet.name + " Toggled", message: newOutlet.name + " has been toggled on/off.", preferredStyle: UIAlertControllerStyle.Alert)
//            let okay = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
//            alert.addAction(okay)
//                
//            if !newOutlet.active {
//                outlet!.active = true
//                setStatus(newOutlet)
//            }
//            else {
//                outlet!.active = false
//                statusLabel.text = "Status: Inactive"
//                statusImage.image = UIImage(named: "Inactive")
//            }
//                
//            self.presentViewController(alert, animated: true, completion: nil)

        }
    }

//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }

}
