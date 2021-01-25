//
//  EmailConfigurationUC.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/13/21.
//

import Foundation
import Cocoa

class EmailConfigurationUC: NSViewController {
    
    //MARK property
    @IBOutlet weak var txt_smtp_host: NSTextField!
    @IBOutlet weak var txt_port: NSTextField!
    @IBOutlet weak var txt_username: NSTextField!
    @IBOutlet weak var txt_password: NSTextField!
    @IBOutlet weak var txt_display_name: NSTextField!
    @IBOutlet weak var txt_from_addr: NSTextField!
    @IBOutlet var txt_to_addr: NSTextView!
    @IBOutlet var txtLog: NSTextView!
    
    var timer:Timer?;
    
    //MARK ACTION
    @IBAction func onClickApply(_ sender: Any) {
        saveData();
    }
    
    override func viewDidLoad() {
        loadData();
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshLog), userInfo: nil, repeats: true)
    }
    
    @objc func refreshLog(){
        let msg = Logger.Instance.getMsg();
        txtLog.string = msg;
    }
    
    func saveData(){
        EmailSettings.Instance.SMTP_HOST = txt_smtp_host.stringValue
        EmailSettings.Instance.PORT =
            Int(txt_port.stringValue) ?? 0;
        EmailSettings.Instance.USERNAME = txt_username.stringValue
        EmailSettings.Instance.PASSWORD = txt_password.stringValue
        EmailSettings.Instance.DISPLAY_NAME = txt_display_name.stringValue
        EmailSettings.Instance.FROM_ADDRESS = txt_from_addr.stringValue
        
        let to_list = txt_to_addr.string
        EmailSettings.Instance.TO_LIST = to_list.components(separatedBy: CharacterSet.newlines);
        
        EmailSettings.Instance.save()
        
    }
    
    func loadData(){
        EmailSettings.Instance.load()
        txt_smtp_host.stringValue = EmailSettings.Instance.SMTP_HOST
        if EmailSettings.Instance.PORT == 0 {
            txt_port.stringValue = "";
        }
        else {
            txt_port.stringValue = String(EmailSettings.Instance.PORT)
        }
        
        txt_username.stringValue = EmailSettings.Instance.USERNAME
        txt_password.stringValue = EmailSettings.Instance.PASSWORD
        txt_display_name.stringValue = EmailSettings.Instance.DISPLAY_NAME
        txt_from_addr.stringValue = EmailSettings.Instance.FROM_ADDRESS
        
        let to_list = EmailSettings.Instance.TO_LIST.joined(separator: "\n")
        txt_to_addr.string = to_list
        
    }
    
}

