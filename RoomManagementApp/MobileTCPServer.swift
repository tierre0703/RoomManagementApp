//
//  MobileTCPServer.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/15/21.
//

import Foundation
import Cocoa
import SwiftAsyncSocket


class Message {
    var EmployeeId:Int;
    var Msg: String;
    
    init(employeeId:Int, msg:String) {
        self.EmployeeId = employeeId;
        self.Msg = msg;
    }
}

class MobileTCPServer: SwiftAsyncSocketDelegate  {
    
    static var Instance = MobileTCPServer();
    
    var Connections:[Int:SwiftAsyncSocket] = [:];
    
    var ConnectionsTimespans:[Int:TimeInterval] = [:];
    
    var timer:Timer?
    var ConnectionTimer:Timer?
    
    var MessageQueue = Queue<Message>();
    
    var server: SwiftAsyncSocket?
    var port: UInt16 = 7777
    
    
    init(){
        server = SwiftAsyncSocket(delegate: nil, delegateQueue: DispatchQueue.global(), socketQueue: nil);
        server?.delegate = self;
        //server initialization
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(OnTimedEvent), userInfo: nil, repeats: true)
        
        ConnectionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(OnTimedEvent2), userInfo: nil, repeats: true)
    }
    
    @objc func OnTimedEvent() {
        for item in Connections {
            var emp = EmployeeFactory.Instance.TryGet(Id: item.key)
            
            if emp == nil {
                continue;
            }
            
            let employeeId = emp!.Id ?? 0;
            
            var connected = false;
            if(item.value.isConnected)
            {
                item.value.write(data: "PING:".data(using: .utf8)!, timeOut: 1.0, tag:PKT_CODE.PKT_PING )
                connected = true;
            }
            else
            {
                connected = false;
            }
            
            if(connected == false) {
                print("\nMObile :: " + (emp?.Name ?? "") + " Off-line");
                Connections.removeValue(forKey: item.key)
                if(emp != nil) {
                    var timespanStr = "00:00:00:00";
                    if(ConnectionsTimespans.keys.contains(item.key))
                    {
                        let timespan = ConnectionsTimespans[item.key];
                        timespanStr = timespan?.stringFormmated() ?? "00:00:00:00"
                    }
                    Callback.Instance.NotifyMobileAppStatus(employeeId: employeeId, status: MobileAppStatus(
                        _Employee: emp!.Name, EmployeeId: employeeId, _Status: "Off-line", _Uptime: timespanStr, _IpAddress: item.value.localAddress as? String ?? ""
                    ))
                }
            }
            else
            {
                if var timespan = ConnectionsTimespans[item.key] {
                    var newT = timespan + 10.0;
                    ConnectionsTimespans[item.key] = newT;
                }
            }
        }
    }
    
    
    func _OnTimerEvent2() {
        
        while(true) {
            if ( MessageQueue.IsEmpty() == true ) {
                return;
            }
            
            var message = MessageQueue.peek() as? Message;
            if(Connections.keys.contains(message?.EmployeeId ?? 0)){
                Send(connection: Connections[message?.EmployeeId ?? 0]!, data: message!.Msg);
                MessageQueue.dequeue();
            }
            else
            {
                
            }
        }
    }
    
    func Send(connection: SwiftAsyncSocket, data:String) {
        connection.write(data: data.data(using: .utf8)!, timeOut: 1.0, tag: 0)
    }
    
    func SendAll(data:String) {
        
        for item in Connections {
            if item.value.isConnected {
                item.value.write(data: data.data(using: .utf8)!, timeOut: 1.0, tag: 0)
            }
        }
    }
    
    func StopAll() {
        timer?.invalidate();
        timer = nil;
        
        SendAll(data: ConnectionStrings.DISCONNECT);
        Connections.removeAll()
        server?.disconnect();
    }
    
    @objc func OnTimedEvent2() {
        _OnTimerEvent2()
    }
    
    func Initialize() {
        print("\n---------------------------------");
        print("\nInitializing Mobile TCP Server on Port 7777");
        
        server?.disconnect()
        do {
            try server?.accept(port: port)
        } catch {
            print("\nMobileTCPServer->Initialize() error", error);
        }
        
        print("\n---------------------------------");
    }
    
    
    
    func socket(_ socket: SwiftAsyncSocket, didAccept newSocket: SwiftAsyncSocket) {
        print("\nMobile :: No Of Connections : " + String(Connections.count) );
    }
    
    func socket(_ socket: SwiftAsyncSocket, didWriteDataWith tag: Int) {
    }
    
    func socket(_ socket: SwiftAsyncSocket, didRead data: Data, with tag: Int) {
        
        let dataStr = data as? String ?? "";
        
        print("/nMobileTCPServer RECEIVED ::" + dataStr);
        
        if(dataStr.count > 0) {
            let connectionToken = "BBCB_NC"
            let authToken = "AUTH:";
            let acceptToken = "ACCEPT:"
            let cancelToken = "CANCEL:"
            let mpingToken = "MPING:"
            
            if let range: Range<String.Index> = dataStr.range(of: connectionToken) {
                let index: Int = dataStr.distance(from: dataStr.startIndex, to: range.lowerBound);
                
                if(index >= 0) {
                    socket.write(data: ConnectionStrings.CONNECTION_ESTABLISHED.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_CONNECTION_ESTABLISHED)
                }
                
            } else if let range:Range<String.Index> = dataStr.range(of: authToken) {
                let index: Int = dataStr.distance(from: dataStr.startIndex, to: range.lowerBound);
                
                if(index >= 0) {
                    print("\nNew Authentication Request");
                    var dataIndex = dataStr.index(dataStr.startIndex, offsetBy: (index + authToken.count));
                    let repeaterRange = dataIndex..<dataStr.endIndex;
                    let sub: String = dataStr[repeaterRange] as? String ?? "";
                    
                    let colonSplit = sub.split(separator: ":");
                    let arr = colonSplit[0].split(separator: "\0")
                    var username = "";
                    var password = "";
                    
                    for item in arr {
                        if(item.starts(with: "U-") == true) {
                            let startIndex = item.index(item.startIndex, offsetBy: "U-".count);
                            
                            username = item[startIndex..<item.endIndex] as? String ?? ""
                        }
                        else if (item.starts(with: "P-") == true) {
                            let startIndex = item.index(item.startIndex, offsetBy: "P-".count);
                            password = item[startIndex..<item.endIndex] as? String ?? ""
                        }
                    }
                    
                    if (username != "" && password != "") {
                        
                        print("\nUsername-" + username + " Password-" + password);
                        var emp = EmployeeService.Instance.CheckEmployeeAuth(username: username, password: password)
                        if(emp != nil) {
                            let employeeId = emp?.Id ?? 0;

                            print("\nAuthentication Successful :: Employee Name-" + (emp!.Name));
                            socket.write(data: ConnectionStrings.AUTHENTICATED.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_AUTH)
                            let detailStr:String = ConnectionStrings.EMP_DETAILS + String(employeeId) + ":" + (emp!.Name) + ":";
                            socket.write(data: detailStr.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_DETAIL);
                            
                            
                            if(Connections.keys.contains(employeeId)) {
                                var con = Connections[employeeId];
                                con?.disconnect()
                                Connections.removeValue(forKey: employeeId)
                            }
                            
                            Connections[employeeId] = socket;
                            if !ConnectionsTimespans.keys.contains(employeeId) {
                                ConnectionsTimespans[employeeId] = TimeInterval(0);
                            }
                            
                            let timerInterval = ConnectionsTimespans[employeeId]
                            
                            let upTime = timerInterval?.stringFormmated()
                            
                            var mobileStatus = MobileAppStatus(
                                _Employee: emp!.Name, EmployeeId: employeeId,  _Status: "Running", _Uptime: upTime!, _IpAddress: socket.localAddress as? String ?? ""
                            );
                            Callback.Instance.NotifyMobileAppStatus(employeeId: employeeId, status: mobileStatus)
                        }
                        else
                        {
                            print("\nAuthentication Failed");
                            socket.write(data: ConnectionStrings.NOT_AUTHENTICATED.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_NOT_AUTH)
                        }
                    }
                    else
                    {
                        print("\nAuthentication Failed");
                        socket.write(data: ConnectionStrings.NOT_AUTHENTICATED.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_NOT_AUTH)
                    }
                }
            }
            else if let range:Range<String.Index> = dataStr.range(of: acceptToken) {
                let index: Int = dataStr.distance(from: dataStr.startIndex, to: range.lowerBound);
                
                if(index >= 0) {
                    var dataIndex = dataStr.index(dataStr.startIndex, offsetBy: (index + acceptToken.count));
                    let repeaterRange = dataIndex..<dataStr.endIndex;
                    let sub: String = dataStr[repeaterRange] as? String ?? "";
                    if(sub.count > 0) {
                        let colonSplit = sub.split(separator: ":");
                        let id = Int(colonSplit[1]) ?? 0;
                        let val = colonSplit[0] as? String ?? ""
                        print("Accept Call :: Employee ID-" + String(id) + " :: " + val);
                        CallService.Instance.ReceiveCallAcceptRespond(employeeId: id, uniqueId: val)
                    }
                }
            }
            else if let range:Range<String.Index> = dataStr.range(of: cancelToken) {
                let index: Int = dataStr.distance(from: dataStr.startIndex, to: range.lowerBound);
                
                if(index >= 0) {
                    var dataIndex = dataStr.index(dataStr.startIndex, offsetBy: (index + cancelToken.count));
                    let repeaterRange = dataIndex..<dataStr.endIndex;
                    let sub: String = dataStr[repeaterRange] as? String ?? "";
                    if(sub.count > 0) {
                        let colonSplit = sub.split(separator: ":");
                        let id = Int(colonSplit[1]) ?? 0;
                        let val = colonSplit[0] as? String ?? ""
                        print("Cancel Call :: Employee ID-" + String(id) + " :: " + val);
                        CallService.Instance.ReceiveCallCancelRespond(employeeId: id, uniqueId: val)
                    }
                }
            }
            else if let range:Range<String.Index> = dataStr.range(of: mpingToken) {
                let index: Int = dataStr.distance(from: dataStr.startIndex, to: range.lowerBound);
                
                if(index >= 0) {
                    print("Ping.. " + (socket.localAddress as? String ?? ""));

                }
            }
        }
    }
    
    func socket(_ socket: SwiftAsyncSocket?, didDisconnectWith error: SwiftAsyncSocketError?) {
        /*
        guard let key = socket?.userData as? String else {return}
        Connections.removeValue(forKey: key);
 */
    }
    
    
    
}
