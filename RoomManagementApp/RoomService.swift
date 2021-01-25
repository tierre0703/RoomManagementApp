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
        
        print("\n-------------------------------------------");
        print("\nInitializing Rooms");
        for item in list {
            print("\n" + item.Number);
            RoomFactory.Instance.TryAdd(Id: item.Id!, room: item);
        }
        print("\n-------------------------------------------");
    }
    
    
}
