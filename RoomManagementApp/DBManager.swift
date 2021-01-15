//
//  DBManager.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/5/21.
//

import Foundation
import SQLite
import Cocoa

class DBManager
{
    static var _conn:Connection?=nil
    
    static func getCon()->Connection?
    {
        if _conn == nil
        {
            let fileManager = FileManager.default;
            let userDirectory = fileManager.homeDirectoryForCurrentUser
            
            let folderURL = userDirectory.appendingPathComponent("/StewardCallSystem")
            
            if(!fileManager.fileExists(atPath: folderURL.path))
            {
                do{
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                }catch{
                    print("Directory Creation failed", error);
                    return nil;
                }
            }
            
            let DB_FILE = folderURL.appendingPathComponent("/database.db");
            
            do
            {
                if(!fileManager.fileExists(atPath: DB_FILE.path))
                {
                    _conn = try Connection(DB_FILE.absoluteString);
                    createDB()
                }
                else
                {
                    _conn = try Connection(DB_FILE.absoluteString);
                   
                }
            }
            catch
            {
                
            }
        }
        
        return _conn;
    }
    
    
    static func createDB()
    {
        do
        {
            var stmt = try _conn?.prepare(
                """
                CREATE TABLE IF NOT EXISTS Call (
                Id    integer NOT NULL,
                UniqueId  nvarchar(50) COLLATE NOCASE,
                EmployeeId    integer,
                RoomId    integer,
                IsAccepted    bit,
                TimeStamp nvarchar(50),
                ANSWERTimeStamp nvarchar(50),
                FOREIGN KEY(EmployeeId) REFERENCES Employee(Id),
                FOREIGN KEY(RoomId) REFERENCES Room(Id),
                PRIMARY KEY(Id AUTOINCREMENT)
                );
                """)
            
            try stmt?.run()
            
            stmt = try _conn?.prepare(
                """
                CREATE TABLE IF NOT EXISTS Email2(
                    Id    integer NOT NULL,
                    Email nvarchar(50) COLLATE NOCASE,
                    PRIMARY KEY(Id AUTOINCREMENT)
                );
                """)
            try stmt?.run()
            
            
            stmt = try _conn?.prepare(
            """
            CREATE TABLE IF NOT EXISTS Employee(
                Id    integer NOT NULL,
                Name  nvarchar(50) COLLATE NOCASE,
                Username  nvarchar(50) COLLATE NOCASE,
                Password  nvarchar(50) COLLATE NOCASE,
                PRIMARY KEY(Id AUTOINCREMENT)
            );
            """
            )
            
            try stmt?.run()
            
            stmt = try _conn?.prepare(
            """
            CREATE TABLE IF NOT EXISTS Room(
                Id    integer NOT NULL,
                UniqueId  nvarchar(50) NOT NULL COLLATE NOCASE,
                Number    nvarchar(50) COLLATE NOCASE,
                PRIMARY KEY(Id AUTOINCREMENT)
            );
            """
            )
            
            try stmt?.run()
            
            stmt = try _conn?.prepare(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS Room_IX_Room ON Room(
                Id    DESC
            );
            """
            )
            try stmt?.run()
            
            stmt = try _conn?.prepare(
            """
            CREATE TRIGGER [fki_Call_EmployeeId_Employee_Id] Before Insert ON[Call] BEGIN SELECT RAISE(ROLLBACK, 'insert on table Call violates foreign key constraint fki_Call_EmployeeId_Employee_Id') WHERE NEW.EmployeeId IS NOT NULL AND(SELECT Id FROM Employee WHERE Id = NEW.EmployeeId) IS NULL; END;
            """
            )
            try stmt?.run()
            
            stmt = try _conn?.prepare(
            """
            CREATE TRIGGER[fku_Call_EmployeeId_Employee_Id] Before Update ON[Call] BEGIN SELECT RAISE(ROLLBACK, 'update on table Call violates foreign key constraint fku_Call_EmployeeId_Employee_Id') WHERE NEW.EmployeeId IS NOT NULL AND(SELECT Id FROM Employee WHERE Id = NEW.EmployeeId) IS NULL; END;
            """
            )
            try stmt?.run()
            
            stmt = try _conn?.prepare(
            """
            CREATE TRIGGER[fkd_Call_EmployeeId_Employee_Id] Before Delete ON[Employee] BEGIN SELECT RAISE(ROLLBACK, 'delete on table Employee violates foreign key constraint fkd_Call_EmployeeId_Employee_Id') WHERE(SELECT EmployeeId FROM Call WHERE EmployeeId = OLD.Id) IS NOT NULL; END;
            """
            )
            try stmt?.run()
            
            stmt = try _conn?.prepare(
            """
            CREATE TRIGGER[fki_Call_RoomId_Room_Id] Before Insert ON[Call] BEGIN SELECT RAISE(ROLLBACK, 'insert on table Call violates foreign key constraint fki_Call_RoomId_Room_Id') WHERE NEW.RoomId IS NOT NULL AND(SELECT Id FROM Room WHERE Id = NEW.RoomId) IS NULL; END;
            """
            )
            try stmt?.run()
            
            stmt = try _conn?.prepare(
            """
            CREATE TRIGGER[fku_Call_RoomId_Room_Id] Before Update ON[Call] BEGIN SELECT RAISE(ROLLBACK, 'update on table Call violates foreign key constraint fku_Call_RoomId_Room_Id') WHERE NEW.RoomId IS NOT NULL AND(SELECT Id FROM Room WHERE Id = NEW.RoomId) IS NULL; END;
            """
            )
            try stmt?.run()
            
            stmt = try _conn?.prepare(
            """
            CREATE TRIGGER[fkd_Call_RoomId_Room_Id] Before Delete ON[Room] BEGIN SELECT RAISE(ROLLBACK, 'delete on table Room violates foreign key constraint fkd_Call_RoomId_Room_Id') WHERE(SELECT RoomId FROM Call WHERE RoomId = OLD.Id) IS NOT NULL; END;
            """
            )
            try stmt?.run()
            

        }
        catch {
            
        }
    }
    
    
    static func procDeleteCall(_id:Int64)
    {
        let tblCall = Table("Call");
        let Id = Expression<Int64?>("Id")
        
        let condition = tblCall.filter(Id == _id)
        
        do
        {
            try _conn?.run(condition.delete());

        }
        catch {
            print("procDeleteCall Failed", error);
        }
    }
    
    static func deleteReader()
    {
        
    }
    
    
    static func procGetDailyAcceptedCallsByEmployee(_EmployeeId:Int, _FromDate:String, _ToDate:String)->Statement?
    {
        let cmdText =
            """
            SELECT Id, UniqueId, RoomId, TimeStamp, ANSWERTimeStamp, IsAccepted, EmployeeId FROM Call WHERE (EmployeeId = ?) AND ([TimeStamp] BETWEEN ? AND ?) AND (IsAccepted=1)
            """
        
        do
        {
            let stmt = try _conn?.prepare(cmdText)
            return try stmt?.run(_EmployeeId, _FromDate, _ToDate)

        }
        catch
        {
            
        }
        
        return nil;
    }
    
    
    static func procGetEmailList()->Statement?
    {
        let cmdText = "SELECT Id, Email from Email2";
        
        
        do
        {
            let stmt = try _conn?.prepare(cmdText)
            return stmt;
        }
        catch
        {
            print("\nprocGetEmailList", error)
        }
        return nil;
    }
    
    
    static func procInsertEmail(_email:String)
    {
        let cmdText =
        """
        INSERT INTO Email2 (Email) VALUES(?)
        """;
        
        do
        {
            let stmt = try _conn?.prepare(cmdText)
            try stmt?.run(_email)
        }
        catch
        {
            print("\nprocInsertEmail Failed", error)
        }
    }
    
    static func procUpdateEmail(_id: Int64, _email: String)
    {
        let cmdText = "UPDATE Email2 SET Email=? WHERE Id=?"
        
        do{
            
            let stmt = try _conn?.prepare(cmdText)
            try stmt?.run(_email, _id)
        }
        catch{
            print("\nprocUpdateEmail Failed", error)
        }
    }
    
    
    static func procDeleteEmail(_id:Int64)
    {
        let tblEmail = Table("Email2");
        let Id = Expression<Int64?>("Id")
        
        let condition = tblEmail.filter(Id == _id)
        
        do
        {
            try _conn?.run(condition.delete());

        }
        catch {
            print("procDeleteEmail Failed", error);
        }
    }
    
    
    static func procUpdateCall(_UniqueId:String, _EmployeeId:Int, _IsAccepted:Int)
    {
        let date = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let _ANSWERTimeStamp = dateFormat.string(from: date)
        
        let cmdText =
        """
        UPDATE Call SET EmployeeId=?, IsAccepted=?, ANSWERTimeStamp=? WHERE UniqueId=?
        """
        
        do
        {
           let stmt = try _conn?.prepare(cmdText)
           try stmt?.run(_EmployeeId, _IsAccepted, _ANSWERTimeStamp, _UniqueId)
        }
        catch
        {
            print("\nprocUpdateCall Failed", error)
        }
    }
    
    static func procInsertCall(_UniqueId:String, _RoomId:Int, _IsAccepted:Int, _TimeStamp:String, _ANSWERTimeStamp:String)
    {
        let cmdText =
        """
        INSERT INTO Call (UniqueId, RoomId, IsAccepted, TimeStamp, ANSWERTimeStamp) VALUES(?, ?, ?, ?, ?)
        """;
        
        do
        {
            let stmt = try _conn?.prepare(cmdText)
            try stmt?.run(_UniqueId, _RoomId, _IsAccepted, _TimeStamp, _ANSWERTimeStamp)
        }
        catch
        {
            print("\nprocInsertCall", error)
        }
    }
    
    
    static func procGetRoomList()->Statement?
    {
        let cmdText = "SELECT Id,UniqueId,Number from Room"
        
        do
        {
            
            let stmt = try _conn?.prepare(cmdText)
            
            return stmt;
        }
        catch
        {
            print("\nprocGetRoomList Failed", error);
        }
        
        return nil;
    }
    
    static func procInsertRoom(_UniqueId:String, _RoomName:String)
    {
        
        let cmdText = "INSERT INTO Room (UniqueId, Number) VALUES (?, ?)";
        
        do
        {
            let stmt = try _conn?.prepare(cmdText);
            try stmt?.run(_UniqueId, _RoomName)
            
        }
        catch
        {
            print("\nprocInsertRoom", error);
            
        }
    }
    
    static func procUpdateRoom(_id:Int64, _UniqueId:String, _RoomName:String)
    {
        let cmdText = "UPDATE Employee SET UniqueId=?, Number=? WHERE Id=?";
        
        do{
            let stmt = try _conn?.prepare(cmdText)
            try stmt?.run(_UniqueId, _RoomName, _id)
            
        }
        catch
        {
            print("\nprocUpdateRoom", error)
        }
    }
    
    static func procDeleteRoom(_id:Int64){
        let tblRoom = Table("Room");
        let Id = Expression<Int64?>("Id")
        
        let condition = tblRoom.filter(Id == _id)
        
        do
        {
            try _conn?.run(condition.delete());

        }
        catch {
            print("procDeleteRoom Failed", error);
        }
    }
    
    static func procGetRecentUnacceptedCall(_FromDate:String,
                                            _ToDate:String)->Statement?
    {
        let cmdText =
        """
        SELECT Id, UniqueId, RoomId, TimeStamp, ANSWERTimeStamp, IsAccepted FROM Call WHERE (TimeStamp BETWEEN ? AND ?) AND (IsAccepted=0)
        """;
        
        do
        {
            let stmt = try _conn?.prepare(cmdText);
            let ret = try stmt?.run(_FromDate, _ToDate)
            
            return ret;
        }
        catch
        {
            print("\nprocGetRecentUnacceptedCall Failed", error);
            
        }
        
        return nil;
    }
    
    static func procGetEmployeeUCList()->Statement?
    {
        let cmdText = "SELECT Id AS id_p, ROW_NUMBER() OVER(ORDER BY Id)  AS ID, Name, Username, Password FROM Employee"
        
        do
        {
            let stmt = try _conn?.prepare(cmdText)
            //return try stmt?.run()
            return stmt;
        }
        catch
        {
            print("\nprocGetEmplyeeUCList Failed", error)
        }
        
        return nil;
    }
    
    static func procInsertEmployee(_name:String, _username:String, _password:String)
    {
        
        let cmdText = "INSERT INTO Employee (Name, Username, Password) VALUES (?, ?, ?)";
        
        do
        {
            let stmt = try _conn?.prepare(cmdText);
            try stmt?.run(_name, _username, _password)
            
        }
        catch
        {
            print("\nprocInsertEmployee", error);
            
        }
    }
    
    static func procUpdateEmployee(_id:Int64, _name:String, _username:String, _password:String)
    {
        let cmdText = "UPDATE Employee SET Name=?, Username=?, Password=? WHERE Id=?";
        
        do{
            let stmt = try _conn?.prepare(cmdText)
            try stmt?.run(_name, _username, _password, _id)
            
        }
        catch
        {
            print("\nprocUpdateEmployee", error)
        }
        
    }
    
    static func procDeleteEmployee(_id:Int64)
    {
        let tblEmployee = Table("Employee");
        let Id = Expression<Int64?>("Id")
        
        let condition = tblEmployee.filter(Id == _id)
        
        do
        {
            try _conn?.run(condition.delete());

        }
        catch {
            print("procDeleteEmployee Failed", error);
        }
    }
}



