//
//  EmailFactory.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/13/21.
//

import Foundation
import Cocoa

class EmailFactory {
    
    static var Instance = EmailFactory();
    var Cache:[Int64:String] = [:]
    
    func Init() {
        var con = DBManager.getCon()
        var stmt = DBManager.procGetEmailList()
        if stmt == nil {
            return;
        }
        for row in stmt! {
            let Id = row[0] as? Int64 ?? 0;
            let email = row[1] as? String ?? "";
            if(email == "") {
                continue;
            }
            
            Cache[Id] = email;
            
        }
        
    }
    func TryAdd(Id: Int64, email: String) {
        
        Cache[Id] = email;
    }
    
    func TryRemove(Id:Int64) {
        Cache.removeValue(forKey: Id)
    }
    
    func GetAll()->[Int64:String] {
        return Cache;
    }
    
    func Clear() {
        Cache.removeAll()
    }
}
