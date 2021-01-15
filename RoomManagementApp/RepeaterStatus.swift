//
//  RepeaterStatus.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/11/21.
//

import Foundation
import Cocoa

class RepeaterStatus {
    
    var AppId: String?;
    var Status: String?;
    var Uptime: String?;
    var IpAddress: String?;
    
    init(_appId:String, _status:String, _ipAddress:String, _upTime:String) {
        self.AppId = _appId;
        self.Status = _status;
        self.IpAddress = _ipAddress;
        self.Uptime = _upTime;
    }
}
