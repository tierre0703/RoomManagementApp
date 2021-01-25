//
//  EmployeeData.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/18/21.
//

import Foundation
import Cocoa

class EmployeeData {
    
    static var Instance = EmployeeData();
    func GetAllEmployees()->[EmployeeStruct]? {
        var employeeList:[EmployeeStruct] = [];
        
        var _conn = DBManager.getCon()
        
        let stmt = DBManager.procGetEmployeeUCList()
        if(stmt != nil) {
            for row in stmt! {
                
                let Id = row[0] as? Int ?? 0
                let ID = row[1] as? Int ?? 0
                let Name = row[2] as? String ?? ""
                let Username = row[3] as? String ?? ""
                let Password = row[4] as? String ?? ""
                
                employeeList.append(EmployeeStruct(
                    Id: Id,
                    Name: Name,
                    Username: Username,
                    Password: Password
                ));
            }

        }
        
        return employeeList;
    }
}
