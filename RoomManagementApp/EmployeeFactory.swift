//
//  EmployeeFactory.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/15/21.
//

import Foundation
import Cocoa

class EmployeeFactory {
    
    static var Instance = EmployeeFactory();
    
    var Cache:[Int64:EmployeeStruct] = [:]
    
    func GetByName(name:String)->EmployeeStruct? {
        for v in Cache {
            if v.value.Name == name {
                return v.value;
            }
        }
        return nil;
    }
    
    func GetById(Id: Int)->EmployeeStruct? {
        
        for v in Cache {
            if v.value.Id == Id {
                return v.value;
            }
        }
        return nil;
    }
    
    func TryGet(Id:Int)->EmployeeStruct? {
        if Cache.keys.contains(Int64(Id)){
            return Cache[Int64(Id)];
        }
        
        return nil;
    }
    
    func TryAdd(Id:Int, employee:EmployeeStruct){
        Cache[Int64(Id)] = employee
    }
    
    func GetAll()->[Int64:EmployeeStruct] {
        return Cache;
    }
    		
}


