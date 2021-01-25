//
//  EmailMgntUC.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/11/21.
//

import Foundation
import Cocoa

typealias Email = (
    p_id: Int64?,
    ID: Int64?,
    Email: String?
)

class EmailMgntUC: NSViewController {
    //MARK property
    @IBOutlet weak var tblEmail: NSTableView!
    
    
    
    //MARK action
    
    @IBAction func onEnterEmail(_ sender: NSTextField) {
        let selectedRowNumber = tblEmail.selectedRow
        insertNewItem(curLineNumber: selectedRowNumber)
        EmailList[selectedRowNumber].Email = sender.stringValue;
    }
    
    
    @IBAction func onDeleteAction(_ sender: Any) {
        let selectedNumber = tblEmail.selectedRowIndexes.count;
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
                Logger.Instance.AddLog(msg: "alert button handler none")
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
    
    @IBAction func onUpdateAction(_ sender: Any) {
        UpdateAction()
    }
    
    
    var EmailList:[Email] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData();

        tblEmail.delegate = self;
        tblEmail.dataSource = self;
        tblEmail.target = self;
        //tblUser.doubleAction = #selector(tableViewDoubleClick(_:))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func insertNewItem(curLineNumber: Int) {
        if(curLineNumber == EmailList.count){
            var lineNumber = Int64(curLineNumber + 1);
            EmailList.append(Email(p_id:0, ID: lineNumber, Email: ""))
            
            tblEmail.reloadData();
        }
    }
    
    
    
    
    func loadData()
    {
        EmailList.removeAll()
        
        let con = DBManager.getCon()!;
        
        do{
            let stmt = try con.prepare("SELECT Id AS id_p, ROW_NUMBER() OVER(ORDER BY Id)  AS ID, Email FROM Email2")
            //let stmt = DBManager.procGetRoomList()!;
            
            for row in stmt {
                let p_id = row[0] as? Int64
                let Id = row[1] as? Int64
                let email = row[2] as? String
                
                
                EmailList.append(Email(p_id: p_id ?? 0, ID: Id ?? 0, Email: email ?? ""));
                
            }
        }
        catch{
            Logger.Instance.AddLog(msg: "\n EmailMgntUC->loadData() error", error: error);
        }
        
    }
    
    func DeleteAction()
    {
        let selectedIndexes = tblEmail.selectedRowIndexes
        
        for index in selectedIndexes {
            if(EmailList.count <= index){
                continue;
            }
            
            let email = EmailList[index];
            if(email.p_id != 0)
            {
                DBManager.procDeleteEmail(_id: email.p_id!);
            }
        }
        
        // show modal diag
        let alert = NSAlert();
        alert.informativeText = "Successfully Deleted!"
        alert.messageText = "Delete"
        alert.alertStyle = .warning

        let result = alert.runModal()
        
        
        loadData();
        tblEmail.reloadData()
        //ServiceHandler.ServiceResart();
    }
    
    func UpdateAction()
    {
        for email in EmailList {
            if(email.Email == ""){
                continue;
            }
            if (email.p_id == 0)
            {
                //insert
                DBManager.procInsertEmail (_email: email.Email ?? "")
            }
            else
            {
                DBManager.procUpdateEmail(_id: email.p_id ?? 0, _email: email.Email ?? "")
            }
            
        }
        
        
        let alert = NSAlert();
        alert.informativeText = "Successfully Updated!"
        alert.messageText = "Update"
        alert.alertStyle = .warning

        let result = alert.runModal()
        
        
        loadData();
        tblEmail.reloadData()
        //ServiceHandler.ServiceResart();
    }
    
    
    func updateStatus()
    {
        
    }
}




extension EmailMgntUC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return EmailList.count + 1;
    }
}

extension EmailMgntUC: NSTableViewDelegate {
    fileprivate enum CellIdentifiers{
        static let cellID = "cellID"
        static let cellEmail = "cellEmail"
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text:String = "";
        var cellIdentifier:String = "";
        
       
        
        if (tableColumn == tableView.tableColumns[0]) {
            
            if (EmailList.count > row)
            {
                let item = EmailList[row];
                text = String(item.ID ?? 0);
            }

            cellIdentifier = CellIdentifiers.cellID;
        }else if (tableColumn == tableView.tableColumns[1]){
            if (EmailList.count > row)
            {
                let item = EmailList[row];
                text = item.Email ?? "";
            }
            cellIdentifier = CellIdentifiers.cellEmail;
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSTableCellView;
        cell.textField?.stringValue = text;
        
        
        return cell;
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
    
}
