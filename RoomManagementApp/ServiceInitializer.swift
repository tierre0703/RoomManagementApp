//
//  ServiceInitializer.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/19/21.
//

import Foundation
import Cocoa

class ServiceInitializer {

    static func InitializeAll() {
        EmployeeService.Instance.Initialize()
        RoomService.Instance.Initialize()
        EmailService.Instance.Initialize()
    }
    
    
}
