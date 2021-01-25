//
//  CallService.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/17/21.
//

import Foundation
import Cocoa

class CallService {
    
    static var Instance = CallService()
    
    
    var Timer2:Timer?;
    
    func LoadRecentUnacceptedCalls() {
        
        var fromDate = Date();
        fromDate.addTimeInterval(-10 * 60);
        var dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var toDate = Date();
        
        var fromDateStr = dateFormatter.string(from: fromDate)
        var toDateStr = dateFormatter.string(from: toDate)
        var calls = CallData.Instance.GetRecentUnacceptedCalls(fromDate: fromDateStr, toDate: toDateStr);
        Logger.Instance.AddLog(msg: "\n--------------------------------------");
        Logger.Instance.AddLog(msg: "\nNo of Unaccepted Calls - Last 10 Minutes - " + String(calls?.count ?? 0));
        for call in calls! {
            CallFactory.Instance.Add(id: call.UniqueId!, call: call)
            let timeStamp = call.TimeStamp ?? "";
            let roomId = call.Room?.UniqueId ?? "";
            let uniqueId = call.UniqueId ?? "";
            let outputStr = "\n" + timeStamp + " " + roomId + " " + uniqueId;
            Logger.Instance.AddLog(msg: outputStr);
        }
        Logger.Instance.AddLog(msg: "\n--------------------------------------");
    }
    
    func StartUnacceptedCallCheck() {
        
        Timer2 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(OnTimerEvent2), userInfo: nil, repeats: true)
    }
    
    func StopUnacceptedCallCheck() {
        Timer2?.invalidate()
        Timer2 = nil
    }
    
    
    @objc func OnTimerEvent2() {
        var now = Date();
        for item in CallFactory.Instance.Cache {
        
            
            var sentDate = Date.fromDatatypeValue(item.value.TimeStamp)
            if(item.value.Accepted && now.distance(to: sentDate) >= 30.0 ) {
                Logger.Instance.AddLog(msg: "RECALL :: " + (item.value.Room!.Number ?? "") + " " + (item.value.UniqueId ?? ""));
                Recall(call: item.value);
            }
        }
    }
    
    func Recall(call:CallStruct) {
        call.CancelledList.removeAll();
        let time = Date();
        let timeFormatter = DateFormatter();
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeStr = timeFormatter.string(from: time)
        call.TimeStamp = timeStr;
        
        MobileTCPServer.Instance.SendAll(data: ConnectionStrings.RECALL + call.UniqueId! + ":" + call.Room!.Number + ":");
        
    }
    
    func ReceiveNewCall(call: CallStruct) {
        Logger.Instance.AddLog(msg: "\nReceiveNewCall");
        let callUniqueId = call.UniqueId ?? ""
        let callRoomNumber = call.Room?.Number ?? ""
        CallFactory.Instance.Add(id: callUniqueId, call: call);
        MobileTCPServer.Instance.SendAll(data: (ConnectionStrings.CALL + callUniqueId + ":" + callRoomNumber + ":"));
        //here will be push notification
        //async task
        CallData.Instance.SaveCall(mObj: call);
    }
    
    func ReceiveNewTestCall(call: CallStruct) {
        let callUniqueId = call.UniqueId ?? ""
        let callRoomNumber = call.Room?.Number ?? ""
        CallFactory.Instance.Add(id: call.UniqueId!, call: call)
        MobileTCPServer.Instance.SendAll(data: (ConnectionStrings.TESTCALL + callUniqueId + ":" + callRoomNumber + ":"));
    }
    
    func ReceiveCallAcceptRespond(employeeId:Int, uniqueId: String)
    {
        //lock
        var call = CallFactory.Instance.GetByUniqueId(name: uniqueId);
        if(call != nil && call?.Accepted == false) {
            var e = EmployeeFactory.Instance.TryGet(Id: employeeId);
            if(e != nil) {
                call?.Employee = e
                call?.Accepted = true
                let callEmployeeId = call!.Employee?.Id ?? 0
                let callUniqueId = call!.UniqueId ?? ""
                
                if(MobileTCPServer.Instance.Connections.keys.contains(callEmployeeId)){
                    if let con = MobileTCPServer.Instance.Connections[callEmployeeId] {
                        
                        con.write(data: (ConnectionStrings.CALL_APPROVED + uniqueId).data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_APPROVED);
                    }
                    else
                    {
                        MobileTCPServer.Instance.MessageQueue.enqueue(Message(
                            employeeId: callEmployeeId, msg: (ConnectionStrings.CALL_APPROVED + uniqueId + ":")
                        ))
                        
                    }
                }else {
                    MobileTCPServer.Instance.MessageQueue.enqueue(Message(
                        employeeId: callEmployeeId, msg: (ConnectionStrings.CALL_APPROVED + uniqueId + ":")
                    ))
                }
                
                CallFactory.Instance.TryRemove(id: callUniqueId);
                
                for item in MobileTCPServer.Instance.Connections {
                    if item.key == employeeId {
                        continue;
                    }
                    
                    if ((call?.CancelledList.contains(callEmployeeId)) != nil) {
                        continue;
                    }
                    let bufStr = ConnectionStrings.CALL_CANCELLED + uniqueId + ":";
                    item.value.write(data: bufStr.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_CANCELLED)
                }
                
                for item in ExternalClientTCPServer.Instance.Connections {
                    let buf = "CALLACCEPTED:" + call!.Room!.Number + ":" + call!.Employee!.Name + ":\n";
                    item.value.write(data: buf.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_ACCEPTED);
                }
                
                //AsyncTask???
                CallData.Instance.UpdateCall(mObj: call!)
                var calls = CallFactory.Instance.GetAll();
                for item in calls {
                    let itemRoomId = (item.value.Room?.Id ?? 0)
                    let callRoomId = (call?.Room?.Id ?? 0)
                    if(itemRoomId == callRoomId) {
                        CallFactory.Instance.TryRemove(id: item.value.UniqueId!)
                        CallData.Instance.DeleteCall(mObj: item.value)
                    }
                }
            }
        }
        else {
            let rejectData = ConnectionStrings.CALL_REJECTED + uniqueId + ":";
            if(MobileTCPServer.Instance.Connections.keys.contains(employeeId)) {
                var con = MobileTCPServer.Instance.Connections[employeeId];
                if(con != nil) {
                    con?.write(data: rejectData.data(using: .utf8)!, timeOut: 1.0, tag: PKT_CODE.PKT_REJECTED)
                }
                else
                {
                    MobileTCPServer.Instance.MessageQueue.enqueue(Message(employeeId: (call?.Employee?.Id)!, msg: rejectData));
                }
            }
            else
            {
                MobileTCPServer.Instance.MessageQueue.enqueue(Message(employeeId: (call?.Employee?.Id)!, msg: rejectData));
            }
            
        }
    }
    
    func ReceiveCallCancelRespond(employeeId:Int, uniqueId:String) {
        var call = CallFactory.Instance.GetByUniqueId(name: uniqueId)
        
        if(call != nil && call?.Accepted == false) {
            call!.CancelledList.append(employeeId)
            if(call!.CancelledList.count >= MobileTCPServer.Instance.Connections.count) {
                Recall(call: call!);
            }
        }
    }
}
