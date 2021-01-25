//
//  MobileAppStatus.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/11/21.
//

import Foundation
import Cocoa

class MobileAppStatus{
    
    var Employee: String = ""
    var Status: String = ""
    var Uptime: String = ""
    var IpAddress: String = ""
    
    var EmployeeId: Int = 0
    
    
    init(_Employee:String, EmployeeId: Int, _Status:String, _Uptime: String, _IpAddress:String) {
        self.Employee = _Employee
        self.Status = _Status
        self.Uptime = _Uptime
        self.IpAddress = _IpAddress
        self.EmployeeId = EmployeeId;
    }
}
