//
//  EmployeeMgntUC.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/5/21.
//

import Foundation
import Cocoa
import SQLite

class EmployeeMgntUC: NSViewController{
    
    //MARK property
    @IBOutlet weak var tblUser: NSTableView!
    
    
    //MARK action
    @IBAction func onClickDelete(_ sender: Any) {
        let selectedNumber = tblUser.selectedRowIndexes.count;
        if(selectedNumber > 0){
            let alert = NSAlert();
            alert.informativeText = "Are you sure to delete selected records ?"
            alert.messageText = "Confirm Delete!!"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Confirm");
            alert.addButton(withTitle: "Cancel")

            let result = alert.runModal()
            
            switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                //do Confirm Deletion
                DeleteAction()
                break
            case NSApplication.ModalResponse.alertSecondButtonReturn:
                //do Cancel Deletion
                break
                
            default:
                print("alert button handler none")
            }

        }
        else
        {
            let alert = NSAlert();
            alert.informativeText = "No records selected!"
            alert.messageText = "Delete"
            alert.alertStyle = .warning
            alert.runModal()
        }
        
        
    }
    
    @IBAction func onClickUpdate(_ sender: Any) {
        UpdateAction()
    }
    
    @IBAction func onEnterCellIDTextField(_ sender: NSTextField) {
        //cellID inserting
        let selectedRowNumber = tblUser.selectedRow
        insertNewItem(curLineNumber: selectedRowNumber)
    }
   
    @IBAction func onEnterCellNameTextField(_ sender: NSTextField) {
        //cellName inserting
        let selectedRowNumber = tblUser.selectedRow
        insertNewItem(curLineNumber: selectedRowNumber)
        employList[selectedRowNumber].Name = sender.stringValue;
        
    }
    
    @IBAction func onEnterCellUsernameTextField(_ sender: NSTextField) {
        //cellUsername inserting
        let selectedRowNumber = tblUser.selectedRow
        insertNewItem(curLineNumber: selectedRowNumber)
        
        employList[selectedRowNumber].Username = sender.stringValue
    }
    
    @IBAction func onEnterCellPasswordTextField(_ sender: NSTextField) {
        let selectedRowNumber = tblUser.selectedRow
        insertNewItem(curLineNumber: 	selectedRowNumber)
        
        employList[selectedRowNumber].Password = sender.stringValue
    }
    
    
    //definition
    
    var employList:[Employee] = [];
    
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
    
    func DeleteAction()
    {
        //Delete Action
        
        let selectedIndexes = tblUser.selectedRowIndexes
        
        for index in selectedIndexes {
            if(employList.count <= index){
                continue;
            }
            
            let employee = employList[index];
            if(employee.p_id != 0)
            {
                DBManager.procDeleteEmployee(_id: employee.p_id!);
            }
        }
        
        // show modal diag
        let alert = NSAlert();
        alert.informativeText = "Successfully Deleted!"
        alert.messageText = "Delete"
        alert.alertStyle = .warning

        let result = alert.runModal()
        
        
        loadData();
        tblUser.reloadData()
        //ServiceHandler.ServiceResart();

    }
    
    func UpdateAction()
    {
        for employee in employList {
            if(employee.Name == "" || employee.Username == "" || employee.Password == ""){
                continue;
            }
            if (employee.p_id == 0)
            {
                //insert
                DBManager.procInsertEmployee(_name: employee.Name ?? "", _username: employee.Username ?? "", _password: employee.Password ?? "")
            }
            else
            {
                //update
                DBManager.procUpdateEmployee(_id: employee.p_id ?? 0, _name:employee.Name ?? "", _username: employee.Username ?? "", _password: employee.Password ?? "")
            }
            
        }
        
        
        let alert = NSAlert();
        alert.informativeText = "Successfully Updated!"
        alert.messageText = "Update"
        alert.alertStyle = .warning

        let result = alert.runModal()
        
        
        loadData();
        tblUser.reloadData()
        //ServiceHandler.ServiceResart();
    }
    
    func insertNewItem(curLineNumber: Int) {
        if(curLineNumber == employList.count){
            var lineNumber = Int64(curLineNumber + 1);
            employList.append(Employee(p_id:0, Id:lineNumber, Name:"", Username: "", Password: ""))
            
            tblUser.reloadData();
        }
        
    }
    
    
    
    func loadData()
    {
        employList.removeAll()
        
        let con = DBManager.getCon()!;
        
        do{
            let stmt = try con.prepare("SELECT Id AS id_p, ROW_NUMBER() OVER(ORDER BY Id)  AS ID, Name, Username, Password FROM Employee")// DBManager.procGetEmployeeUCList();
            for row in stmt {
                let p_id = row[0] as! Int64
                let Id = row[1] as! Int64
                let Name = row[2] as! String
                let Username = row[3] as! String
                let Password = row[4] as! String
                
                employList.append( Employee(p_id: p_id, Id: Id, Name: Name, Username: Username, Password: Password))	;
            }
        }
        catch{
            
        }
    }
    
    
    func reloadFileList() {
        //load data
        tblUser.reloadData();
    }
    
    func updateStatus()
    {
        let itemSelected = tblUser.selectedRowIndexes.count;
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject){
        
    }
}


extension EmployeeMgntUC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return employList.count + 1;
    }
}

extension EmployeeMgntUC: NSTableViewDelegate {
    fileprivate enum CellIdentifiers{
        static let cellID = "cellID"
        static let cellName = "cellName"
        static let cellUsername = "cellUsername"
        static let cellPassword = "cellPassword"
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text:String = "";
        var cellIdentifier:String = "";
        
       
        
        if (tableColumn == tableView.tableColumns[0]) {
            
            if (employList.count > row)
            {
                let item = employList[row];
                text = String(item.Id ?? 0);
            }

            cellIdentifier = CellIdentifiers.cellID;
        }else if (tableColumn == tableView.tableColumns[1]){
            if (employList.count > row)
            {
                let item = employList[row];
                text = item.Name ?? "";
            }
            cellIdentifier = CellIdentifiers.cellName;
        }else if (tableColumn == tableView.tableColumns[2]){
            if (employList.count > row)
            {
                let item = employList[row];
                text = item.Username ?? "";
            }
            cellIdentifier = CellIdentifiers.cellUsername;
        }else if (tableColumn == tableView.tableColumns[3]) {
            if (employList.count > row)
            {
                let item = employList[row];
                text = item.Password ?? "";
            }
            cellIdentifier = CellIdentifiers.cellPassword;
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSTableCellView;
        cell.textField?.stringValue = text;
        
        
        return cell;
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
    
}
