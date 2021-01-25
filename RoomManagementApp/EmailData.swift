//
//  EmailData.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/18/21.
//

import Foundation
import Cocoa

class EmailData {
    
    static var Instance = EmailData();
    
    func GetAllEmails()->[EmailStruct]? {
        
        var employeeList: [EmailStruct] = [];
        
        var conn = DBManager.getCon()
        var stmt = DBManager.procGetEmailList();
        
        if(stmt != nil) {
            for row in stmt! {
                
                var Id = row[0] as? Int ?? 0
                var EmailAddress = row[1] as? String ?? "";
                if(Id == 0 || EmailAddress == "") {
                    continue;
                }
                
                employeeList.append(EmailStruct(Id: Id, EmailAdress: EmailAddress));
                
            }

        }
        
        return employeeList;
    }
    
}
