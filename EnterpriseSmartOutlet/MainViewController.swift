//
//  MainViewController.swift
//  EnterpriseSmartOutlet
//
//  Created by Riley McGovern on 3/1/15.
//  Copyright (c) 2015 Riley McGovern. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    // The realm object
    let realm = Realm()
    
    // The array of outlets
    var outlets: [Outlet] = [Outlet]()
    
    // THe IP address string
    var ipAddress: String = ""
    
    // A boolena to tell whther or not to use the mock data
    var mockData: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding the logo to the main screen
        let logoImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 102, height: 44))
        logoImage.contentMode = UIViewContentMode.ScaleAspectFit
        logoImage.image = UIImage(named: "ESOLogo")
        let logoView = UIView(frame: CGRect(x: 0, y: 0, width: logoImage.frame.size.width, height: logoImage.frame.size.height))
        logoView.addSubview(logoImage)
        self.navigationItem.titleView = logoView
        
        // Fixes quick swipe back issue
        self.clearsSelectionOnViewWillAppear = false
        
        // Add pull to refresh on table view
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        self.refreshControl!.addTarget(self, action: "getJson", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        self.tableView.reloadData()
        
        // Check to see if there is a previously used IP Address
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let ip = userDefaults.valueForKey("IP") as? String {
            self.ipAddress = ip
        }
        
        // If the IP Address is blank, then load the mock data
        if self.ipAddress == "" {
            mockData = true
        }
        // Else, load read data from the IP Address
        else {
            mockData = false
        }
        
        // Get either the mock or real JSON data
        getJson()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let row = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(row, animated: animated)
        }
        
        getJson()
    }
    
    func getJson() {
        // Removes all outlets from the array
        outlets.removeAll(keepCapacity: false)
        
        // Checks to see if the app will use mock data or not
        if mockData {
            // Checks to see if it can translate the string into JSON
            if let
                jsonString     = NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("SampleInput", ofType: "json")!, encoding: NSUTF8StringEncoding, error: nil),
                dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
                userList       = NSJSONSerialization.JSONObjectWithData(dataFromString, options: nil, error: nil) as? [String: AnyObject] {
                    // Checks to see if the JSON can be turned into an object
                    if let outletList = userList["outlets"] as? [AnyObject] {
                        // Loads every outlet from the JSON data
                        for outletJSON in outletList {
                            let outlet = Outlet()
                            outlet.macAddress = (outletJSON["mac_address"] as? String)!
                            outlet.voltage = (outletJSON["voltage"] as? Double)!
                            outlet.current = (outletJSON["current"] as? Double)!
                            outlet.name = (outletJSON["outlet_name"] as? String)!
                            outlet.group = (outletJSON["outlet_group"] as? String)!
                            outlet.details = (outletJSON["description"] as? String)!
                            outlet.lastContact = (outletJSON["last_contact"] as? String)!
                            outlets.append(outlet)
                        }
                    }
                    // Refreshes the table
                    self.refreshControl?.beginRefreshing()
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
            }

        }
        
        // Using real data
        else {
            // Creates the URL to the server
            if let url = NSURL(string: "http://" + ipAddress + ":1337/list_all") {
                let urlRequest = NSURLRequest(URL: url)
                NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {(resp: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    // Checks to make sure there were no errors with the URL request
                    if error == nil {
                        // Makes sure the string can be translated to JSON
                        if let userList = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String: AnyObject] {
                            // Checks to make sure the JSON data can be turned into an array
                            if let outletList = userList["outlets"] as? [AnyObject] {
//                                self.realm.write {
//                                    self.realm.deleteAll()
//                                }
                                // Goes through every outlet in the JSON data and checks for nil values
                                for outletJSON in outletList {
                                    let outlet = Outlet()
                                    if let mac = outletJSON["mac_address"] as? String {
                                        outlet.macAddress = mac
                                    }
                                    if let volt = outletJSON["voltage"] as? Double {
                                        outlet.voltage = volt
                                    }
                                    if let cur = outletJSON["current"] as? Double {
                                        outlet.current = cur
                                    }
                                    if let name = outletJSON["outlet_name"] as? String {
                                        outlet.name = name
                                    }
                                    if let group = outletJSON["outlet_group"] as? String {
                                        outlet.group = group
                                    }
                                    if let desc = outletJSON["description"] as? String {
                                        outlet.details = desc
                                    }
                                    if let last = outletJSON["last_contact"] as? String {
                                        outlet.lastContact = last
                                    }
                                    if let active = outletJSON["status"] as? String {
                                        if active == "0" {
                                            outlet.active = false
                                        }
                                        if active == "1" {
                                            outlet.active = true
                                        }
                                    }
                                    // Adds the new outlet to the array
                                    self.outlets.append(outlet)
//                                    self.realm.write {
//                                        self.realm.add(outlet)
//                                    }
                                }
                                // Refreshes the table
                                self.refreshControl?.beginRefreshing()
                                self.tableView.reloadData()
                                self.refreshControl?.endRefreshing()
                            }
                        }
                        // Refreshes the table
                        self.tableView.reloadData()
                    }
                    // Happens if there is an error connecting to the server
                    else {
                        self.refreshControl?.beginRefreshing()
                        let alert = UIAlertController(title: "Server Connection Error", message: "Could not connect to the server. Please double check that you entered the correct IP address.", preferredStyle: UIAlertControllerStyle.Alert)
                        let okay = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alert.addAction(okay)
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.refreshControl?.endRefreshing()
                    }
                })
                // Refreshes the table
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            // Refreshes the table
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeIPButtonPressed(sender: AnyObject) {
        // Creates and brings up an alert to enter in the IP address of the server
        var alert = UIAlertController(title: "Change IP Address", message: "Please enter the IP address of the server.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let save = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            if let textFields = alert.textFields as? [UITextField] {
                let field = textFields[0]
                self.ipAddress = field.text
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(self.ipAddress, forKey: "IP")
                userDefaults.synchronize()
                if self.ipAddress == "" {
                    self.mockData = true
                }
                else {
                    self.mockData = false
                }
                self.getJson()
                self.tableView.reloadData()
            }
        })
        
        alert.addAction(cancel)
        alert.addAction(save)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.DecimalPad
            if self.ipAddress == "" {
                textField.placeholder = "IP Address (ex. 127.0.0.1)"
            }
            else {
                textField.text = self.ipAddress
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
            cell.imageView?.image = UIImage(named: "Inactive")
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
        cell.detailTextLabel?.text = outlets[indexPath.row].group
        
        if outlets[indexPath.row].active == false {
            cell.imageView?.image = UIImage(named: "Inactive")
        }
            
        else if outlets[indexPath.row].current >= 0.01 {
            cell.imageView?.image = UIImage(named: "InUse")
        }
        
        else {
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
