//
//  PushServiceManager.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/25/21.
//

import Foundation
import SimplePushKit


class PushServiceManager {
    
    static var Instance = PushServiceManager()
    
    var router:Router?;
    var controlChannel:Channel?
    var _notificationChannel:Channel?
    
    init() {
    
        router = Router()
        controlChannel = Channel(port: Port.control, type: .control, router: router)
        _notificationChannel = Channel(port: Port.notification, type: .notification, router: router)

    }
    
    func Start() {
        
        controlChannel?.start()
       _notificationChannel?.start()
        Logger.Instance.AddLog(msg: "\nSimplePushServer started. See Console for logs.")
    }
    
}
