//
//  RoomService.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/19/21.
//

import Foundation
import Cocoa

class RoomService {
    
    static var Instance = RoomService();
    
    func Initialize() {
        
        let uniqueId = UUID().uuidString
        let list = RoomData.Instance.GetAllRooms()
        
        Logger.Instance.AddLog(msg:"\n-------------------------------------------");
        Logger.Instance.AddLog(msg: "\nInitializing Rooms");
        
        for item in list {
            Logger.Instance.AddLog(msg: ("\n" + item.Number));
            RoomFactory.Instance.TryAdd(Id: item.Id!, room: item);
        }
        Logger.Instance.AddLog(msg: "\n-------------------------------------------");
    }
    
    
}
