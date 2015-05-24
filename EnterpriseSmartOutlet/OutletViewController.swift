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

    @IBOutlet weak var voltageLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var inUseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let newOutlet = outlet {
            voltageLabel.text = String(format: "%.2f", newOutlet.voltage)
            currentLabel.text = String(format: "%.2f", newOutlet.current)
            powerLabel.text = String(format: "%.2f", newOutlet.voltage * newOutlet.current)
            locationLabel.text = newOutlet.details
            inUseLabel.text = "\(newOutlet.current >= 0.001)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleButtonPressed(sender: AnyObject) {
        if let newOutlet = outlet {
            //outlet?.onStatus = !(newOutlet.onStatus!)
            //println("Outlet is on: \(outlet?.onStatus)")
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
