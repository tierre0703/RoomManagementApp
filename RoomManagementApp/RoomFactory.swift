//
//  RoomFactory.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/17/21.
//

import Foundation
import Cocoa

class RoomFactory {
    
    static var Instance = RoomFactory();
    
    var Cache:[Int:RoomStruct] = [:];
    
    func GetByUniqueId(name: String)->RoomStruct? {
        
        for room_itor in Cache {
            if(room_itor.value.UniqueId == name) {
                return room_itor.value;
            }
        }
        
        return nil;
    }
    
    
    func GetById(Id: Int)->RoomStruct? {
        for room_itor in Cache {
            if(room_itor.value.Id == Id) {
                return room_itor.value;
            }
        }
        
        return nil;
    }
    
    func TryAdd(Id:Int, room:RoomStruct) {
        Cache[Id] = room;
    }
}
