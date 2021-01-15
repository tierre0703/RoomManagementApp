//
//  MobileAppStatusUC.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/11/21.
//

import Foundation
import Cocoa

class MobileAppStatusUC: NSViewController {
    
    //MARK property
    @IBOutlet weak var tblUser: NSTableView!
    
    
    //MARK action
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData();

        tblUser.delegate = self;
        tblUser.dataSource = self;
        tblUser.target = self;
        //tblUser.doubleAction = #selector(tableViewDoubleClick(_:))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadData(){
        
        var connection = true;
        
        if connection == true {
            print("\nConnecting to Service")
            //var list = NamedPipeConnector.Contract.GetMobileAppStatus()
            //MobileAppStatusFactory.Instance.UpdateList(list)
            print("\nConnection Established with Service")
        }
        else
        {
            MobileAppStatusFactory.Instance.UpdateWaiting();
            
            
            let alert = NSAlert();
            alert.informativeText = "Couldn't connect to server. Server might be stopped ?"
            alert.messageText = "Connection Error with Server!!"
            alert.alertStyle = .warning
            
            let result = alert.runModal()
        }
        
    }
    
    
    func updateStatus(){
        
    }
    
}





extension MobileAppStatusUC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return MobileAppStatusFactory.Instance.StatusList.count;
    }
}

extension MobileAppStatusUC: NSTableViewDelegate {
    fileprivate enum CellIdentifiers{
        static let cellEmployee = "cellEmployee"
        static let cellStatus = "cellStatus"
        static let cellUptime = "cellUptime"
        static let cellIPAddress = "cellIPAddress"
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text:String = "";
        var cellIdentifier:String = "";
        
        var color = NSColor.red
        
        if (tableColumn == tableView.tableColumns[0]) {
            
            if (MobileAppStatusFactory.Instance.StatusList.count > row)
            {
                let item = MobileAppStatusFactory.Instance.StatusList[row];
                text = item.Employee;
            }

            cellIdentifier = CellIdentifiers.cellEmployee;
        }else if (tableColumn == tableView.tableColumns[1]){
            if (MobileAppStatusFactory.Instance.StatusList.count > row)
            {
                let item = MobileAppStatusFactory.Instance.StatusList[row];
                text = item.Status ?? "";
                if text == "Running" {
                    color = NSColor.green
                }
                else if text == "Off-line" {
                    color = NSColor.red
                }
                else
                {
                    color = NSColor.orange
                }
            }
            cellIdentifier = CellIdentifiers.cellStatus;
        }
        else if (tableColumn == tableView.tableColumns[2]){
            if (MobileAppStatusFactory.Instance.StatusList.count > row)
            {
                let item = MobileAppStatusFactory.Instance.StatusList[row];
                text = item.Uptime ?? "";
            }
            cellIdentifier = CellIdentifiers.cellUptime;
        }else if (tableColumn == tableView.tableColumns[3]){
            if (MobileAppStatusFactory.Instance.StatusList.count > row)
            {
                let item = MobileAppStatusFactory.Instance.StatusList[row];
                text = item.IpAddress ?? "";
            }
            cellIdentifier = CellIdentifiers.cellIPAddress;
        }
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSTableCellView;
        cell.textField?.stringValue = text;
        
        if (tableColumn == tableView.tableColumns[1]){
            cell.textField?.textColor = color
        }
        
        return cell;
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
    
}


