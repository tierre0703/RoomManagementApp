//
//  RepeaterTCPServer.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/12/21.
//

import Foundation
import Cocoa

import SwiftSocket

class RepeaterTCPServer {
    static var Instance = RepeaterTCPServer()
    
    
    var Connections:[String:TCPClient] = [:]
    var ConnectionsTimespan:[String:Int] = [:]
    
    var timer:Timer? = nil;
    var ConnectionEmailTimer:Timer? = nil;
    
    var server:TCPServer? = nil;
    
    var lastEmailSentTimes:[String:Date] = [:];
    
    init(){
        
        //server initialization
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(OnTimedEvent), userInfo: nil, repeats: true)
        
        ConnectionEmailTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(OnTimedEvent2), userInfo: nil, repeats: true)
    }
    
    @objc func OnTimedEvent() {
        for item in Connections {
            var connected = false;
            do {
                switch item.value.send(string: "T") {
                case .success:
                    connected = true;
                    
                case .failure(let error):
                    connected = false;
                    print(error)
                }
                
                if(connected == false) {
                    print("Repeater Disconnected - " + item.value.address);
                    Connections.removeValue(forKey: item.value.address);
                }
            } catch {
                print("\n OnTimedEvent Error", error);
            }
            
        }
    }
    
    @objc func OnTimedEvent2() {
        
    }
    
    
    
    func Initialize() {
        
    }
}
