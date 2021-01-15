//
//  EmailSettings.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/13/21.
//

import Foundation
import Cocoa

class EmailSettings
{
    static var Instance = EmailSettings();
    
    var SMTP_HOST:String = ""
    var PORT: Int = 0
    var USERNAME: String = ""
    var PASSWORD: String = ""
    var FROM_ADDRESS:String = ""
    var DISPLAY_NAME: String = ""
    
    
    var TO_LIST: [String] = []
    
    
    func load()
    {
        let defaults = UserDefaults.standard
        SMTP_HOST = defaults.object(forKey: "SMTP_HOST") as? String ?? "";
        PORT = defaults.integer(forKey: "PORT") ;
        USERNAME = defaults.object(forKey: "USERNAME") as? String ?? "";
        PASSWORD = defaults.object(forKey: "PASSWORD") as? String ?? "";
        FROM_ADDRESS = defaults.object(forKey: "FROM_ADDRESS") as? String ?? "";
        DISPLAY_NAME = defaults.object(forKey: "DISPLAY_NAME") as? String ?? "";
        
        TO_LIST = defaults.object(forKey: "TO_LIST") as? [String] ?? [String]()
    }
    
    func save(){
        let defaults = UserDefaults.standard
        
        defaults.set(SMTP_HOST, forKey: "SMTP_HOST");
        defaults.set(PORT, forKey: "PORT");
        defaults.set(USERNAME, forKey: "USERNAME");
        defaults.set(PASSWORD, forKey: "PASSWORD");
        defaults.set(FROM_ADDRESS, forKey: "FROM_ADDRESS");
        defaults.set(DISPLAY_NAME, forKey: "DISPLAY_NAME");
        defaults.set(TO_LIST, forKey: "TO_LIST");
    }
}
