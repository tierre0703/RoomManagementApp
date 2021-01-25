//
//  EmployeeService.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/19/21.
//

import Foundation
import Cocoa


class EmployeeService {
    
    static var Instance = EmployeeService()
    
    func Initialize() {
        var dao = EmployeeData.Instance;
        var list = dao.GetAllEmployees()
        Logger.Instance.AddLog(msg: "\n-----------------------------------------------")
        Logger.Instance.AddLog(msg: "\nInitializing Employees");
        for item in list! {
            Logger.Instance.AddLog(msg: "\n" + item.Name);
            EmployeeFactory.Instance.TryAdd(Id: item.Id!, employee: item)
        }
        Logger.Instance.AddLog(msg: "\n-----------------------------------------------")
    }
    
    func CheckEmployeeAuth(username:String, password:String)->EmployeeStruct? {
        let items = EmployeeFactory.Instance.GetAll();
        for item in items {
            if(item.value.Username == username && item.value.Password == password) {
                return item.value;
            }
        }
        
        return nil;
    }
}
