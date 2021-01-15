//
//  MobileAppStatusFactory.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/11/21.
//

import Foundation
import Cocoa



class MobileAppStatusFactory{
    
    static var Instance = MobileAppStatusFactory()
    
    var StatusList:[MobileAppStatus] = []
    
    
    init() {
       
    }
    
    func Get(_employeeId:Int)->Int {
            
        for index in 0..<StatusList.count {
            
            if(StatusList[index].EmployeeId == _employeeId){
                
                return index;
            }
        }
        
        return -1;
    }
    
    func InitList(list:[MobileAppStatus])
    {
        StatusList.removeAll();
        
        for item in list {
            StatusList.append(item)
        }
    }
    
    
    func UpdateWaiting() {
        for index in 0..<StatusList.count {
            StatusList[index].Status = "Waiting"
        }
    }
    
    
    func UpdateList(list:[MobileAppStatus]){

        for index in 0..<StatusList.count {
            for list_index in 0..<list.count {
                
                if(StatusList[index].EmployeeId == list[list_index].EmployeeId){
                    
                    StatusList[index].Status = list[list_index].Status;
                    StatusList[index].IpAddress = list[list_index].IpAddress;
                    StatusList[index].Uptime = list[list_index].Uptime;

                    break;
                }
            }

        }
    }
}
