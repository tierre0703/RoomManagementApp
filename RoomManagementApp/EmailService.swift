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
        print("\n--------------------------");
        print("\nInitializing Emails");
        for item in list! {
            print("\n" + item.EmailAdress);
            EmailFactory.Instance.TryAdd(Id: Int64(item.Id), email: item)
        }
    
        print("\n--------------------------");
    }
}
