//
//  EmailService.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/13/21.
//

import Foundation
import Cocoa

class EmailService {
    
    static func Initialize(){
        //retrieve mail from DB
        print("\n--------------------------");
        EmailFactory.Instance.Init();
    
        print("\n--------------------------");
    }
}
