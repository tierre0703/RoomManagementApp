//
//  Model.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/18/21.
//

import Foundation

class CallStruct {
    var UniqueId:String?;
    var Room: RoomStruct?;
    var Employee: EmployeeStruct?;
    var Accepted: Bool = false;
    var TimeStamp: String = "";
    var ANSWERTimeStamp: String = "";
    var CancelledList:[Int] = [];
    
    init(UniqueId: String, Room: RoomStruct, Employee: EmployeeStruct?, Accepted: Bool, TimeStamp: String, ANSWERTimeStamp: String) {
        self.UniqueId = UniqueId;
        self.Room = Room;
        self.Employee = Employee;
        self.Accepted = Accepted;
        self.TimeStamp = TimeStamp;
        self.ANSWERTimeStamp = ANSWERTimeStamp;
    }
    
    init(UniqueId: String, Accepted: Bool, TimeStamp: String) {
        self.UniqueId = UniqueId;
        self.Accepted = Accepted;
        self.TimeStamp = TimeStamp;
    }
}

class EmployeeStruct {
    var Id:Int?
    var Name: String = ""
    var Username: String = ""
    var Password: String = ""
    
    init(Id: Int, Name: String, Username: String, Password: String) {
        self.Id = Id
        self.Name = Name
        self.Username = Username
        
    }
}

class EmailStruct {
    var Id:Int = 0;
    var EmailAdress:String = ""
    
    init(Id:Int, EmailAdress:String) {
        self.Id = Id;
        self.EmailAdress = EmailAdress
    }
}


class RoomStruct {
    var Id: Int?
    var UniqueId: String = ""
    var Number: String = ""
    
    init(Id: Int, UniqueId: String, Number: String) {
        self.Id = Id
        self.UniqueId = UniqueId;
        self.Number = Number;
    }
}

