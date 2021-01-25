//
//  RoomData.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/18/21.
//

import Foundation
import Cocoa

class RoomData {
    
    static var Instance = RoomData()
    
    func GetAllRooms()->[RoomStruct] {
        var roomList:[RoomStruct] = []
        
        var conn = DBManager.getCon();
        let stmt = DBManager.procGetRoomList();
        
        if(stmt != nil) {
            for row in stmt! {
                let Id = row[0] as? Int ?? 0
                let UniqueId = row[1] as? String ?? ""
                let Number = row[2] as? String ?? ""
                
                if(Id == 0) {
                    continue;
                }
                
                roomList.append(RoomStruct(Id: Id, UniqueId: UniqueId, Number: Number))
            }
        }
        
        
        return roomList;
    }
}
