//
//  Logger.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/25/21.
//

import Foundation
import Cocoa

class Logger {
    
    static var Instance = Logger();
    
    var msg = "";
    
    func AddLog(msg: String){
        self.msg.append(msg)
    }
    
    func AddLog(msg: String, error: Error) {
        self.msg.append(msg);
        let desc = "\(error)";
        self.msg.append(desc);
    }
    
    func getMsg()->String {
        return self.msg;
    }
}
