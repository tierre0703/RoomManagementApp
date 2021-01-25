//
//  CallData.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/17/21.
//

import Foundation
import Cocoa


class CallData {
    static var Instance = CallData()
    
    func SaveCall(mObj: CallStruct)->String
    {
        var success = ""
        var conn = DBManager.getCon()
        
        
        DBManager.procInsertCall(_UniqueId: mObj.UniqueId!, _RoomId: mObj.Room!.Id!, _IsAccepted: Int(mObj.Accepted == true ? 1 : 0), _TimeStamp: mObj.TimeStamp, _ANSWERTimeStamp: mObj.ANSWERTimeStamp)
        
        success = "Sucess"
        
        return success;
    }
    
    func UpdateCall(mObj: CallStruct)->String {
        var conn = DBManager.getCon()
        
        DBManager.procUpdateCall(_UniqueId: mObj.UniqueId!, _EmployeeId: mObj.Employee!.Id!, _IsAccepted: Int(mObj.Accepted == true ? 1 : 0))
        return "Sucess"
    }
    
    func DeleteCall(mObj: CallStruct)->String {
        var conn = DBManager.getCon()
        
        DBManager.procDeleteCall(_UniqueId: mObj.UniqueId!)
        return "Sucess"
    }
    
    func GetDailyAcceptedCallsByEmployee(employeeId:Int, fromDate: String, toDate: String)->[CallStruct] {
        
        var callList:[CallStruct] = [];
        
        var conn = DBManager.getCon()
        
        var stmt = DBManager.procGetDailyAcceptedCallsByEmployee(_EmployeeId: employeeId, _FromDate: fromDate, _ToDate: toDate);
        
        for row in stmt! {
            let Id = row[0] as? Int ?? 0;
            let UniqueId = row[1] as? String ?? "";
            let RoomId = row[2] as? Int ?? 0;
            let TimeStamp = row[3] as? String ?? "";
            let ANSWERTimeStamp = row[4] as? String ?? "";
            let IsAccepted = row[5] as? Int ?? 0;
            let EmployeeId = row[6] as? Int ?? 0;
            
            callList.append(CallStruct(
                UniqueId:UniqueId ?? "",
                Room: RoomFactory.Instance.GetById(Id: RoomId)!,
                Employee: EmployeeFactory.Instance.GetById(Id: EmployeeId) ?? nil,
                Accepted: false,
                TimeStamp: TimeStamp ?? "",
                ANSWERTimeStamp: ANSWERTimeStamp ?? "")
            )
        }
        
        return 	callList;
    }
    
    func GetRecentUnacceptedCalls(fromDate: String, toDate: String)->[CallStruct]? {
        var callList:[CallStruct] = [];
        var conn = DBManager.getCon()
        var stmt = DBManager.procGetRecentUnacceptedCall(_FromDate: fromDate, _ToDate: toDate)
        
        if(stmt == nil) {
            return callList;
        }
        for row in stmt! {
            let Id = row[0] as? Int ?? 0;
            let UniqueId = row[1] as? String ?? "";
            let RoomId = row[2] as? Int ?? 0;
            let TimeStamp = row[3] as? String ?? "";
            let ANSWERTimeStamp = row[4] as? String ?? "";
            let IsAccepted = row[5] as? Int ?? 0;
            let EmployeeId = row[6] as? Int ?? 0;
           
            callList.append(CallStruct(
                UniqueId:UniqueId ?? "",
                Room: RoomFactory.Instance.GetById(Id: RoomId)!,
                Employee: nil,
                Accepted: false,
                TimeStamp: TimeStamp ?? "",
                ANSWERTimeStamp: ANSWERTimeStamp ?? "")
            )
            
        }
        
        return callList;
    }
    
}

