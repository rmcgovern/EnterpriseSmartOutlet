//
//  Outlet.swift
//  EnterpriseSmartOutlet
//
//  Created by Riley McGovern on 3/1/15.
//  Copyright (c) 2015 Riley McGovern. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Outlet: Object {
    
    dynamic var macAddress: String = "MAC Address Not Found"
    dynamic var voltage: Double = -1.0
    dynamic var current: Double = -1.0
    dynamic var name: String = "Name Not Found"
    dynamic var group: String = "Group Not Found"
    dynamic var details: String = "Description Not Found"
    dynamic var lastContact: String = "Last Contact Not Found"
    dynamic var active: Bool = true
    
    convenience init(id: Int!, macAddress: String!, voltage: Double!, current: Double!, name: String!, details: String!) {
        self.init()
        
        self.macAddress = macAddress
        self.voltage = voltage
        self.current = current
        self.name = name
        self.details = details
    }
}

class OutletTableViewCell: UITableViewCell {
    var outlet: Outlet?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}