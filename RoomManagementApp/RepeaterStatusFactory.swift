//
//  RepeaterStatusFactory.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/12/21.
//

import Foundation
import Cocoa

class RepeaterStatusFactory {
    
    static var Instance = RepeaterStatusFactory()
    
    var StatusList:[RepeaterStatus] = []
    
    init() {
        
    }
    
    func UpdateWaiting(){
        for index in 0..<StatusList.count {
            StatusList[index].Status = "Waiting"
        }
    }
    
    func Get(appId: String)->Int
    {
        for index in 0..<StatusList.count {
            if StatusList[index].AppId == appId {
                return index;
            }
        }
        return -1;
    }
    
    func UpdateList( list: [RepeaterStatus] ) {
        for index in 0..<list.count {
            var found = false;
            for s_index in 0..<StatusList.count {
                if(list[index].AppId == StatusList[s_index].AppId) {
                    StatusList[s_index].Status = list[index].Status;
                    StatusList[s_index].IpAddress = list[index].IpAddress;
                    StatusList[s_index].Uptime = list[index].Uptime;
                    found = true;
                    break;
                }
            }
            
            if found == false {
                StatusList.append(list[index])
            }
            
        }
    }
    
    
}
