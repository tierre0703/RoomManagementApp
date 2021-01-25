//
//  RepeaterTCPServer.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/12/21.
//

import Foundation
import Cocoa
import SwiftAsyncSocket


class RepeaterTCPServer: SwiftAsyncSocketDelegate {

    
    static var Instance = RepeaterTCPServer()
    var Connections:[String:SwiftAsyncSocket] = [:]
    var timer:Timer?;
    var ConnectionEmailTimer:Timer?;
    var server:SwiftAsyncSocket?;
    
    var lastEmailSentTimes:[String:Date] = [:];
    var ConnectionsTimeSpans:[String:TimeInterval] = [:];
    var port: UInt16 = 9999
    var canAccept: Bool = false;
    
    var canSendData: ((SwiftAsyncSocket)->Void)?
    var didReadData: ((Data)->Void)?
    

    
    
    func Initialize() {
        print("\n------------------------------------");
        print("\nInitializing Repeater TCP Server on Port 9999");
        
        do {
            canAccept = ((try server?.accept(port: port)) != nil)
            canAccept = true;
        }catch {
            print ("\(error)");
        }
        
        
        print("\nRepeater TCP Server Started");
        print("\n------------------------------------");
    }
    
    init() {
        
        server = SwiftAsyncSocket(delegate: nil, delegateQueue: DispatchQueue.global(), socketQueue: nil);
        server?.delegate = self;
        
       
        
        //server initialization
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(OnTimedEvent), userInfo: nil, repeats: true)
        
        ConnectionEmailTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(OnTimedEvent2), userInfo: nil, repeats: true)
    }
    
    func socket(_ socket: SwiftAsyncSocket, didAccept newSocket: SwiftAsyncSocket) {
        //Connections[key]=newSocket
        let key = newSocket.localAddress as? String ?? "";
        newSocket.userData = key;
        newSocket.delegate = self;
        newSocket.delegateQueue = DispatchQueue.global()
        canSendData?(newSocket)
    }
    
    func socket(_ socket: SwiftAsyncSocket, didWriteDataWith tag: Int) {
    }
    
    func socket(_ socket: SwiftAsyncSocket, didRead data: Data, with tag: Int){
        
        let dataStr = data as? String ?? "";
        
        print("/nRECEIVED ::" + dataStr);
        socket.write(data: "ACK".data(using: .utf8)!, timeOut: 1, tag: PKT_CODE.PKT_ACK)
        
        let keyToken = "H_SHAKE:";
        let callToken = "CALL:";
        if let range: Range<String.Index> = dataStr.range(of: keyToken) {
            let index: Int = dataStr.distance(from: dataStr.startIndex, to: range.lowerBound);
            
            if(index >= 0) {
                let offset = index + keyToken.count;
                let keyIndex = dataStr.index(dataStr.startIndex, offsetBy: offset)
                let repeaterRange = keyIndex..<dataStr.endIndex;
                let str_repeaters: String = dataStr[repeaterRange] as? String ?? "";
                
                let repeaters = str_repeaters.split{$0 == ":"}.map(String.init);
                
                
                if let connection = Connections[repeaters[0]] {
                    Connections.removeValue(forKey: repeaters[0]);
                }
                
                Connections[repeaters[0]] = socket;
                
                if let conTimespan = ConnectionsTimeSpans[repeaters[0]] {
                    
                }
                else
                {
                    ConnectionsTimeSpans[repeaters[0]] = 0;
                }

                let time_str = ConnectionsTimeSpans[repeaters[0]]?.stringFormmated()
                
                //NotifyRepeaterStatus
                Callback.Instance.NotifyRepeaterStatus(status: RepeaterStatus(_appId: repeaters[0], _status: "Running", _ipAddress: (socket.localAddress as? String ?? ""), _upTime: time_str!))

                if let lastEmailTime = lastEmailSentTimes[repeaters[0]] {
                    lastEmailSentTimes.removeValue(forKey: repeaters[0]);
                    lastEmailSentTimes[repeaters[0]] = Date();
                }
                else
                {
                    lastEmailSentTimes[repeaters[0]] = Date();
                }
            }
        } else if let range: Range<String.Index> = dataStr.range(of: callToken) {
            let index: Int = dataStr.distance(from: dataStr.startIndex, to: range.lowerBound);
            
            if(index >= 0) {
                let offset = dataStr.index(dataStr.startIndex, offsetBy: (index + callToken.count))
                let roomTokenRange = offset..<dataStr.endIndex;
                let str_roomIds: String = dataStr[roomTokenRange] as? String ?? "";
                
               let roomIds = str_roomIds.split(separator: ":");
                var room = RoomFactory.Instance.GetByUniqueId(name: (roomIds[0] as? String ?? ""))
                if(room == nil) {
                    print("\nRoom Null");
                    return;
                }
                let uniqueId = UUID().uuidString
                let time = Date();
                let timeFormmater = DateFormatter();
                timeFormmater.dateFormat = "yyyy-MM-dd HH:mm:ss";
                let timeStr = timeFormmater.string(from: time)
                
                let call = CallStruct(UniqueId: uniqueId, Room: room!, Employee: nil, Accepted: false, TimeStamp: timeStr, ANSWERTimeStamp: "");
                CallService.Instance.ReceiveNewCall(call: call)
                
                
                
            }
        }
        
    }
    
    func socket(_ socket: SwiftAsyncSocket?, didDisconnectWith error: SwiftAsyncSocketError?) {
        guard let key = socket?.userData as? String else {return}
        Connections.removeValue(forKey: key);
    }
    
    func _OnTimedEvent() {
        for item in Connections {
            var connected = false;
            let key = item.key
            
            do {
                if(item.value.isConnected) {
                    let ping = "T".data(using: .utf8) ?? Data()
                    try item.value.write(data: ping, timeOut: 1.0, tag: PKT_CODE.PKT_PING)
                    
                    connected = true;
                }
                else {
                    connected = false;
                }
                
                if (connected == false) {
                    print("\nRepeater Disconnected - ", item.key);
                    Connections.removeValue(forKey: item.key);
                    let date = Date();
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let curDate = dateFormat.string(from: date)
                    
                    
                    EmailNotification.Instance.SendAsync(subject: "Repeater Disconnected", body: "A Repeater " + key + " Disconnected\r\n" + curDate)
                    
                    
                    var timespan_str = "00:00:00:00";
                    if let timespan = ConnectionsTimeSpans[item.key] {
                        timespan_str = timespan.stringFormmated() ?? "00: 00:00:00";
                    }
                    
                    Callback.Instance.NotifyRepeaterStatus(status: RepeaterStatus(
                        _appId: item.key, _status: "Off-line", _ipAddress: item.value.localAddress as? String ?? "", _upTime: timespan_str
                    ));
                }
                else {
                    var timespan_str = "00:00:00:00";
                    
                    if(ConnectionsTimeSpans.keys.contains(item.key)) {
                        
                        let timespan = ConnectionsTimeSpans[item.key];
                        let newT = timespan! + 3;
                        
                        ConnectionsTimeSpans[item.key] = newT;
                    }
                }
                
            } catch {
                
                print("\nTimedEvent", error);
                
            }
        }
    }
    
    
    @objc func OnTimedEvent() {
        _OnTimedEvent()
    }
    
    
    
    func _OnTimedEvent2() {
        for item in lastEmailSentTimes {
            var repeater = item.key;
            var time = lastEmailSentTimes[item.key]
            var formmatter = DateFormatter();
            formmatter.dateFormat = "yyyy-MM-dd";
            let last_time = formmatter.string(from: time!);
            let cur_time = formmatter.string(from: Date());
            lastEmailSentTimes.removeValue(forKey: repeater);
            
            print("\nRepeater Connected -" + repeater + " at " + last_time);
            
            EmailNotification.Instance.SendAsync(subject: "Repeater Connected", body: "A Repeater " + repeater + " Connected at " + last_time + "\n" + cur_time);
          
        }
    }
    
    @objc func OnTimedEvent2() {
        _OnTimedEvent2()
    }
    
    
    
    
    func tcpServer_OnDataAvailable(){
        
    }
    
    func StopAll() {
        timer?.invalidate()
        server?.disconnect()
        Connections.removeAll()
    }
    
}
