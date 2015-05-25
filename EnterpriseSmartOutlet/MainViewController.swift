//
//  MainViewController.swift
//  EnterpriseSmartOutlet
//
//  Created by Riley McGovern on 3/1/15.
//  Copyright (c) 2015 Riley McGovern. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper
import RealmSwift

class MainViewController: UITableViewController {
    
    var outlets: [Outlet] = [Outlet]()
    
    var ipAddress: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let realm = Realm()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        self.tableView.addSubview(refreshControl!)
        self.tableView.reloadData()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let ip = userDefaults.valueForKey("IP") as? String {
            self.ipAddress = ip
        }
        
        if self.ipAddress == "" {
            self.refreshControl!.addTarget(self, action: "getMockJson", forControlEvents: UIControlEvents.ValueChanged)
            getMockJson()
        }
        else {
            self.refreshControl!.addTarget(self, action: "getJson", forControlEvents: UIControlEvents.ValueChanged)
            getJson()
        }
        
    }
    
    func getMockJson() {
        outlets.removeAll(keepCapacity: false)
        if let
            jsonString     = NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("SampleInput", ofType: "json")!, encoding: NSUTF8StringEncoding, error: nil),
            dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
            userList       = NSJSONSerialization.JSONObjectWithData(dataFromString, options: nil, error: nil) as? [String: AnyObject] {
            if let outletList = userList["outlets"] as? [AnyObject] {
                for outletJSON in outletList {
                    let outlet = Outlet()
                    outlet.macAddress = (outletJSON["mac_address"] as? String)!
                    outlet.voltage = (outletJSON["voltage"] as? Double)!
                    outlet.current = (outletJSON["current"] as? Double)!
                    outlet.name = (outletJSON["outlet_name"] as? String)!
                    outlet.details = (outletJSON["description"] as? String)!
                    outlets.append(outlet)
                }
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func getJson() {
        outlets.removeAll(keepCapacity: false)
        
        if let url = NSURL(string: "http://" + ipAddress + ":1337/list_all") {
            let urlRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {(resp: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    if error == nil {
                        println(data)
                        if let userList = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String: AnyObject] {
                            if let outletList = userList["outlets"] as? [AnyObject] {
                                for outletJSON in outletList {
                                    let outlet = Outlet()
                                    outlet.macAddress = (outletJSON["mac_address"] as? String)!
                                    outlet.voltage = (outletJSON["voltage"] as? Double)!
                                    outlet.current = (outletJSON["current"] as? Double)!
                                    outlet.name = (outletJSON["outlet_name"] as? String)!
                                    outlet.details = (outletJSON["description"] as? String)!
                                    self.outlets.append(outlet)
                                }
                                self.tableView.reloadData()
                                self.refreshControl?.endRefreshing()
                            }
                        }

                    }
                    else {
                        println(error.description)
                    }
            })
            self.refreshControl?.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeIPButtonPressed(sender: AnyObject) {
        var alert = UIAlertController(title: "Change IP Address", message: "Please enter the IP address of the server.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let save = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            if let textFields = alert.textFields as? [UITextField] {
                let field = textFields[0]
                self.ipAddress = field.text
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(self.ipAddress, forKey: "IP")
                userDefaults.synchronize()
                //println("The new server IP Address is: " + field.text)
                self.tableView.reloadData()
            }
        })
        
        alert.addAction(cancel)
        alert.addAction(save)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.DecimalPad
            if self.ipAddress == "" {
                textField.placeholder = "IP Address (ex. 127.0.0.1)"
                self.refreshControl?.removeTarget(self, action: "getJson", forControlEvents: UIControlEvents.ValueChanged)
                self.refreshControl?.addTarget(self, action: "getMockJson", forControlEvents: UIControlEvents.ValueChanged)
                self.getMockJson()
            }
            else {
                textField.text = self.ipAddress
                self.refreshControl?.removeTarget(self, action: "getMockJson", forControlEvents: UIControlEvents.ValueChanged)
                self.refreshControl?.addTarget(self, action: "getJson", forControlEvents: UIControlEvents.ValueChanged)
                self.getJson()
            }
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        // Create one cell for an error message
        if outlets.count == 0 {
            return 1
        }
        
        return outlets.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("outletCell", forIndexPath: indexPath) as! OutletTableViewCell
        
        // Create an error message if no outlets are found
        if outlets.count == 0 {
            cell.textLabel?.text = "No Outlets Found"
            cell.detailTextLabel?.text = "Please check that the IP Address of the sever is correct."
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            tableView.allowsSelection = false
            return cell
        }
        
        // Reset table after correct IP is entered
        cell.selectionStyle = UITableViewCellSelectionStyle.Default
        tableView.allowsSelection = true

        // Configure the cell...
        cell.outlet = outlets[indexPath.row]
        cell.textLabel?.text = outlets[indexPath.row].name
        
        if outlets[indexPath.row].current >= 0.01 {
            cell.detailTextLabel?.text = "In Use"
            //cell.backgroundColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
            cell.imageView?.image = UIImage(named: "InUse")
        }
        
        else {
            cell.detailTextLabel?.text = "Not In Use"
            //cell.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
            cell.imageView?.image = UIImage(named: "Free")
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // Make the cells unselectable if error message is displayed
        if outlets.count == 0 {
            return nil
        }
        
        return indexPath
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "outletSegue" {
            if let outletVC = segue.destinationViewController as? OutletViewController {
                if let outletCell = sender as? OutletTableViewCell {
                    outletVC.outlet = outletCell.outlet
                    outletVC.navigationItem.title = outletCell.outlet?.name
                    outletVC.ipAddress = self.ipAddress
                }
            }
        }
    }

}
