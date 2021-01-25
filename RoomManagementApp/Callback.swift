//
//  Callback.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/15/21.
//

import Foundation
import Cocoa

class Callback {
    static var Instance = Callback();
    
    func NotifyMobileAppStatus(employeeId:Int, status:MobileAppStatus) {
        let oldId = MobileAppStatusFactory.Instance.Get(_employeeId: employeeId);
        
        if(oldId != -1) {
            MobileAppStatusFactory.Instance.StatusList[oldId].Status = status.Status;
        }
        else
        {
            MobileAppStatusFactory.Instance.StatusList.append(status);
        }
    }
    
    
    func NotifyRepeaterStatus(status:RepeaterStatus) {
        
        let oldId = RepeaterStatusFactory.Instance.Get(appId: status.AppId ?? "");
        
        if (oldId != -1) {
            RepeaterStatusFactory.Instance.StatusList[oldId].Status = status.Status;
        }else {
            RepeaterStatusFactory.Instance.StatusList.append(status);
        }
    }
}
