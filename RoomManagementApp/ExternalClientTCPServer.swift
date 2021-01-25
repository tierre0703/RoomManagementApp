//
//  ExternalClientTCPServer.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/19/21.
//

import Foundation
import Cocoa
import SwiftAsyncSocket

class ExternalClientTCPServer: SwiftAsyncSocketDelegate  {
    static var Instance = ExternalClientTCPServer()
    
    var Connections:[String: SwiftAsyncSocket] = [:]
    var lastEmailSentTimes:[String: Date] = [:]
    
    var port:UInt16 = 8888;
    
    var server:SwiftAsyncSocket?
    
    init() {
        server = SwiftAsyncSocket(delegate: nil, delegateQueue: DispatchQueue.global(), socketQueue: nil);
        server?.delegate = self;
    }
    
    func Initialize() {
        Logger.Instance.AddLog(msg: "\n-----------------------------------------------");
        Logger.Instance.AddLog(msg: "\nInititializing External Client TCP Server on Port 8888");
        server?.disconnect()
        do {
            try server?.accept(port: port)
        } catch {
            Logger.Instance.AddLog(msg: "\nMobileTCPServer->Initialize() error", error: error);
        }
        Logger.Instance.AddLog(msg: "\n-----------------------------------------------")
    }
    
    func StopAll() {
        server?.disconnect()
        Connections.removeAll();
    }
    
    
    
    func socket(_ socket: SwiftAsyncSocket, didAccept newSocket: SwiftAsyncSocket) {
        Logger.Instance.AddLog(msg: "\nExternal Client Connected");
        let key = socket.localAddress as? String ?? ""
        if(Connections.keys.contains(key)) {
            Connections.removeValue(forKey: key)
        }
        
        Connections[key] = socket;
    }
    
    func socket(_ socket: SwiftAsyncSocket, didWriteDataWith tag: Int) {
    }
    
    func socket(_ socket: SwiftAsyncSocket, didRead data: Data, with tag: Int) {
        
        let dataStr = data as? String ?? "";
        
        if(dataStr.count > 0) {
            Logger.Instance.AddLog(msg: "\nEXTERNAL :: RECEIVED :: " + dataStr);
            let callToken = "CALL:";
            var roomNo = "";
            
            if let range: Range<String.Index> = dataStr.range(of: callToken) {
                let index: Int = dataStr.distance(from: dataStr.startIndex, to: range.lowerBound);
                if(index >= 0) {
                    
                    let offset = dataStr.index(dataStr.startIndex, offsetBy: (index + callToken.count));
                    let strRange = offset..<dataStr.endIndex;
                    
                    let roomIds = dataStr[strRange].split(separator: ":");
                    if roomIds.count > 0{
                        roomNo = roomIds[0] as? String ?? "";
                        let room = RoomFactory.Instance.GetByUniqueId(name: roomNo);
                        if(room == nil) {
                            return;
                        }
                        
                        let uniqueId = UUID().uuidString;
                        
                        let nowTime = Date();
                        let dateFormatter = DateFormatter();
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
                        let nowTimeStr = dateFormatter.string(from: nowTime)
                        
                        let call = CallStruct(UniqueId: uniqueId, Accepted: false, TimeStamp: nowTimeStr)
                        CallService.Instance.ReceiveNewCall(call: call);
                        let bufStr = "ACK:" + roomNo + "\n"
                        socket.write(data: bufStr.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_ACK);
                    }
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
