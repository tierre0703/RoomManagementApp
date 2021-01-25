//
//  Contract.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/15/21.
//

import Foundation
import Cocoa

import SwiftAsyncSocket

class Contract {
    
    func GetMobileAppStatus()->[MobileAppStatus] {
        var Connections = MobileTCPServer.Instance.Connections;
        var list:[MobileAppStatus] = [];
        
        for item in Connections {
            var e = EmployeeFactory.Instance.TryGet(Id: item.key);
            if( e != nil) {
                var timespan_str = "00:00:00:00";

                if(MobileTCPServer.Instance.ConnectionsTimespans.keys.contains(Int(e!.Id ?? 0))) {
                    
                    let timespan = MobileTCPServer.Instance.ConnectionsTimespans[Int(e?.Id ?? 0)];

                    if timespan != nil {
                        timespan_str = timespan?.stringFormmated() ?? "00:00:00:00";
                    }
                }
                
                list.append(MobileAppStatus(
                    _Employee: e?.Name ?? "", EmployeeId: (e?.Id)!,  _Status: "Running", _Uptime: timespan_str, _IpAddress: item.value.localAddress as? String ?? ""
                ));
            }
        }
        
        return list;
    }
    
    
    func GetRepeaterStatus()->[RepeaterStatus] {
        var Connections = RepeaterTCPServer.Instance.Connections;
        var list:[RepeaterStatus] = [];
        
        for item in Connections {
            var timespan_str = "00:00:00:00";
            if RepeaterTCPServer.Instance.ConnectionsTimeSpans.keys.contains(item.key) {
                let timespan = RepeaterTCPServer.Instance.ConnectionsTimeSpans[item.key];
                
                timespan_str = timespan?.stringFormmated() ?? "00:00:00:00";
            }
            
            list.append(RepeaterStatus(_appId: item.key, _status: "Running", _ipAddress: item.value.localAddress as? String ?? "", _upTime: timespan_str
            ));
        }
        return list;
    }
    
}


extension TimeInterval {
    
    func stringFormmated() -> String {
        //var milliseconds = self.rounded() * 10;
        //milliseconds = milliseconds.truncatingRemainder(dividingBy: 10)
        let interval = Int(self);
        let second = interval % 60;
        let minutes = (interval / 60) % 60;
        let hours = (interval / 3600) % 24;
        let days = (interval / 3600 / 24);
        
        return String(format: "%02d:%02d:%02d:%02d", days, hours, minutes, second);
    }
}
