//
//  TreeViewController.swift
//  EnterpriseSmartOutlet
//
//  Created by Riley McGovern on 5/19/15.
//  Copyright (c) 2015 Riley McGovern. All rights reserved.
//

import UIKit
import RATreeView

class TreeViewController: UITableViewController, RATreeViewDelegate, RATreeViewDataSource {
    
    var outlets1 = [Outlet]()
    var outlets2 = [Outlet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Tree View"
        self.tableView.removeFromSuperview()

        let treeView = RATreeView(frame: self.view.frame, style: RATreeViewStylePlain)
        treeView.delegate = self
        treeView.dataSource = self
        self.view.addSubview(treeView)
        treeView.registerClass(OutletTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "treeCell").classForCoder, forCellReuseIdentifier: "treeCell")
        treeView.reloadData()
    }
    
    func loadMockData() {
        let outlet1 = Outlet(id: 1, macAddress: nil, voltage: 1.0, current: 1.0, name: "Outlet 1", details: "This is place 1.")
        let outlet2 = Outlet(id: 2, macAddress: nil, voltage: 2.0, current: 2.0, name: "Outlet 2", details: "This is place 2.")
        for i in 1...3 {
            outlets1.append(outlet1)
            outlets2.append(outlet2)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func treeView(treeView: RATreeView!, numberOfChildrenOfItem item: AnyObject!) -> Int {
        return 1
    }
    
    func treeView(treeView: RATreeView!, cellForItem item: AnyObject!) -> UITableViewCell! {
        let cell = treeView.dequeueReusableCellWithIdentifier("treeCell") as! OutletTableViewCell
        //let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "treeCell")
        
        cell.textLabel?.text = "Outlet"
        cell.detailTextLabel?.text = "Details of Outlet"
        
        return cell
    }
    
    func treeView(treeView: RATreeView!, child index: Int, ofItem item: AnyObject!) -> AnyObject! {
        return index
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
