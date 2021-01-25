//
//  EmailService.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/13/21.
//

import Foundation
import Cocoa

class EmailService {
    
    static var Instance = EmailService();
    
    func Initialize(){
        let list = EmailData.Instance.GetAllEmails()
        
        //retrieve mail from DB
        Logger.Instance.AddLog(msg: "\n--------------------------");
        Logger.Instance.AddLog(msg: "\nInitializing Emails");
        for item in list! {
            Logger.Instance.AddLog(msg: "\n" + item.EmailAdress);
            EmailFactory.Instance.TryAdd(Id: Int64(item.Id), email: item)
        }
    
        Logger.Instance.AddLog(msg: "\n--------------------------");
    }
}
