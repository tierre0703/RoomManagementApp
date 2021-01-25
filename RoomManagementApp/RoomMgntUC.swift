//
//  RoomMgntUC.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/10/21.
//

import Foundation
import Cocoa
import SQLite

typealias Room = (
    p_id:Int64?,
    Id:Int64?,
    UniqueId:String?,
    Number:String?
)

class RoomMgntUC: NSViewController{
    
    //MARK action
    @IBAction func onDeleteClick(_ sender: Any) {
        
        let selectedNumber = tblRoom.selectedRowIndexes.count;
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
    
    @IBAction func onUpdateClick(_ sender: Any) {
        UpdateAction();
    }
    
    
    
    @IBAction func onEnterId(_ sender: Any) {
    }
    
    @IBAction func onEnterUniqueId(_ sender: NSTextField) {
        let selectedRowNumber = tblRoom.selectedRow
        insertNewItem(curLineNumber: selectedRowNumber)
        RoomList[selectedRowNumber].UniqueId = sender.stringValue;
    }
    
    @IBAction func onEnterRoomName(_ sender: NSTextField) {
        let selectedRowNumber = tblRoom.selectedRow
        insertNewItem(curLineNumber: selectedRowNumber)
        RoomList[selectedRowNumber].Number = sender.stringValue;
    }
    
    
    //MARK property
    @IBOutlet weak var tblRoom: NSTableView!
    
    
    
    var RoomList:[Room] = [];

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData();

        tblRoom.delegate = self;
        tblRoom.dataSource = self;
        tblRoom.target = self;
        //tblUser.doubleAction = #selector(tableViewDoubleClick(_:))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadData()
    {
        RoomList.removeAll()
        
        let con = DBManager.getCon()!;
        
        do{
            let stmt = try con.prepare("SELECT Id AS p_id, ROW_NUMBER() OVER(ORDER BY Id)  AS Id,  UniqueId, Number FROM Room")
            //let stmt = DBManager.procGetRoomList()!;
            
            for row in stmt {
                let p_id = row[0] as? Int64 ?? 0
                let Id = row[1] as? Int64 ?? 0
                let UniqueId = row[2] as? String ?? ""
                let Number = row[3] as? String ?? ""
                
                RoomList.append(Room(p_id: p_id, Id: Id, UniqueId: UniqueId, Number: Number));
            }
        }
        catch{
            print("\n RoomMgntUC->loadData() error", error);
        }
        
    }
    
    func UpdateAction(){
        for room in RoomList {
            if(room.Number == "" || room.UniqueId == ""){
                continue;
            }
            if (room.p_id == 0)
            {
                //insert
                DBManager.procInsertRoom(_UniqueId: room.UniqueId ?? "", _RoomName: room.Number ?? "")
            }
            else
            {
                //update
                DBManager.procUpdateRoom(_id: room.p_id ?? 0, _UniqueId: room.UniqueId ?? "", _RoomName: room.Number ?? "")
            }
            
        }
        
        
        let alert = NSAlert();
        alert.informativeText = "Successfully Updated!"
        alert.messageText = "Update"
        alert.alertStyle = .warning

        let result = alert.runModal()
        
        
        loadData();
        tblRoom.reloadData()
        //ServiceHandler.ServiceResart();
    }
    
    func insertNewItem(curLineNumber: Int) {
        if(curLineNumber == RoomList.count){
            var lineNumber = Int64(curLineNumber + 1);
            RoomList.append(Room(p_id:0, Id:lineNumber, UniqueId: "", Number: ""))
            
            tblRoom.reloadData();
        }
        
    }
    
    
    func DeleteAction(){
        let selectedIndexes = tblRoom.selectedRowIndexes
        
        for index in selectedIndexes {
            if(RoomList.count <= index){
                continue;
            }
            
            let room = RoomList[index];
            if(room.p_id != 0)
            {
                DBManager.procDeleteRoom(_id: room.p_id!);
            }
        }
        
        // show modal diag
        let alert = NSAlert();
        alert.informativeText = "Successfully Deleted!"
        alert.messageText = "Delete"
        alert.alertStyle = .warning

        let result = alert.runModal()
        
        
        loadData();
        tblRoom.reloadData()
        //ServiceHandler.ServiceResart();
    }
    
    func updateStatus(){
        
    }
}




extension RoomMgntUC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return RoomList.count + 1;
    }
}

extension RoomMgntUC: NSTableViewDelegate {
    fileprivate enum CellIdentifiers{
        static let cellID = "cellID"
        static let cellUniqueId = "cellUniqueID"
        static let cellRoomName = "cellRoomName"
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text:String = "";
        var cellIdentifier:String = "";
        
       
        
        if (tableColumn == tableView.tableColumns[0]) {
            
            if (RoomList.count > row)
            {
                let item = RoomList[row];
                text = String(item.Id ?? 0);
            }

            cellIdentifier = CellIdentifiers.cellID;
        }else if (tableColumn == tableView.tableColumns[1]){
            if (RoomList.count > row)
            {
                let item = RoomList[row];
                text = item.UniqueId ?? "";
            }
            cellIdentifier = CellIdentifiers.cellUniqueId;
        }else if (tableColumn == tableView.tableColumns[2]){
            if (RoomList.count > row)
            {
                let item = RoomList[row];
                text = item.Number ?? "";
            }
            cellIdentifier = CellIdentifiers.cellRoomName;
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSTableCellView;
        cell.textField?.stringValue = text;
        
        
        return cell;
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
    
}
