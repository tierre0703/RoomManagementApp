//
//  RoomServiceMgntService.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/20/21.
//

import Foundation
import Cocoa

class RoomServiceMgntService {
    static var Instance = RoomServiceMgntService();
    
    func OnStop() {
        RepeaterTCPServer.Instance.StopAll();
        MobileTCPServer.Instance.StopAll()
        ExternalClientTCPServer.Instance.StopAll()
        CallService.Instance.StopUnacceptedCallCheck()
        
        EmailReportSchedule.Instance.Stop()
    }
    
    func OnStart() {
        ServiceInitializer.InitializeAll()
        CallService.Instance.LoadRecentUnacceptedCalls()
        RepeaterTCPServer.Instance.Initialize()
        MobileTCPServer.Instance.Initialize()
        ExternalClientTCPServer.Instance.Initialize()
        
        CallService.Instance.StartUnacceptedCallCheck()
        //NamedPipeServiceHost.StartServiceHost
        EmailReportSchedule.Instance.Start()
        
    }
    
}
