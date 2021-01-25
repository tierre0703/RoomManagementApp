//
//  CallFactory.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/18/21.
//

import Foundation
import Cocoa

class CallFactory {
    static var Instance = CallFactory()
    var Cache:[String: CallStruct] = [:];
    
    func GetByUniqueId(name:String)->CallStruct? {
        for call_itor in Cache {
            
            if(call_itor.value.UniqueId == name) {
                return call_itor.value;
            }
        }
        
        return nil
    }
    
    func Add(id:String, call:CallStruct) {
        Cache[id] = call;
    }
    
    func TryRemove(id:String) {
        Cache.removeValue(forKey: id)
    }
    
    func GetAll()->[String: CallStruct] {
        return Cache;
    }
}
