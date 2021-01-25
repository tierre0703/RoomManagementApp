//
//  CallMgntUC.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/11/21.
//

import Foundation
import Cocoa


class Call {
    var p_id: Int64?;
    var Id: Int64?;
    var isAccepted:Int64?;
    var AcceptedUser: String?;
    var Room: String?;
    var CallTime: String?;
    var AnswerTime: String?;
    
    init(p_id: Int64, Id: Int64, isAccepted: Int64, AcceptedUser: String, Room: String, CallTime: String, AnswerTime: String) {
        self.p_id = p_id
        self.Id = Id;
        self.isAccepted = isAccepted
        self.AcceptedUser = AcceptedUser
        self.Room = Room
        self.CallTime = CallTime
        self.AnswerTime = AnswerTime
    }

}

class CallMgntUC:NSViewController{
    
    //MARK action
    @IBAction func onClearHistory(_ sender: Any) {
        
        let historyCount = CallList.count;
        
        if(historyCount > 0){
            let alert = NSAlert();
            alert.informativeText = "Are you sure to delete all the call history?"
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
        
    }
    
    
    
    
    
    
    //MARK property
    @IBOutlet weak var tblCall: NSTableView!
    
    
    var CallList:[Call] = [];
    var timer:Timer? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData();

        tblCall.delegate = self;
        tblCall.dataSource = self;
        tblCall.target = self;
        
        
        //timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshTable), userInfo: nil, repeats: true)
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc func refreshTable(){
        loadData();
        tblCall.reloadData()
    }
    
    func loadData(){
        
        CallList.removeAll()
        
        let date = Date();
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: date)!;
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let fromDateString = dateFormatter.string(from: fromDate)

        let toDateString = dateFormatter.string(from: date)
        
      
        
       let cmdText = "SELECT c.Id AS id_p, ROW_NUMBER() OVER(ORDER BY c.Id DESC) AS ID, e.Name AS AcceptedUser, r.Number AS Room, c.TimeStamp AS CallTime, c.ANSWERTimeStamp AS AnswerTime FROM Call c LEFT JOIN Employee e ON c.EmployeeId=e.Id INNER JOIN Room r ON c.RoomId=r.Id WHERE c.TimeStamp BETWEEN ? AND ? ORDER BY c.Id DESC"
        
        let con = DBManager.getCon()
        
        do{
            let stmt = try con?.prepare(cmdText)
            let rows = try stmt?.run(fromDateString, toDateString)
            
            for row in rows! {
                
                let id_p = row[0] as? Int64 ?? 0
                let ID = row[1] as? Int64 ?? 0
                let AcceptedUser = row[2] as? String ?? ""
                let Room = row[3] as? String ?? ""
                let CallTime = row[4] as? String ?? ""
                let AnswerTime = row[5] as? String ?? ""
                let call = Call(p_id: id_p, Id: ID, isAccepted: Int64(1), AcceptedUser: AcceptedUser, Room: Room, CallTime: CallTime, AnswerTime: AnswerTime)
                CallList.append(call)
            }
            
        }
        catch{
            
            
        }
        
        
    }
    
    
    func DeleteAction()
    {
        //Delete Action
        
        for call_info in CallList {
            
            if(call_info.p_id != 0)
            {
                DBManager.procDeleteCall(_id: call_info.p_id ?? 0)
            }
        }
        
        // show modal diag
        let alert = NSAlert();
        alert.informativeText = "Successfully Deleted!"
        alert.messageText = "Delete"
        alert.alertStyle = .warning

        let result = alert.runModal()
        
        
        loadData();
        tblCall.reloadData()
        //ServiceHandler.ServiceResart();
    }
    
    func updateStatus()
    {
        
    }
}




extension CallMgntUC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return CallList.count;
    }
}

extension CallMgntUC: NSTableViewDelegate {
    fileprivate enum CellIdentifiers{
        static let cellID = "cellID"
        static let cellAcceptedUser = "cellAcceptedUser"
        static let cellRoom = "cellRoom"
        static let cellCallTime = "cellCallTime"
        static let cellAnswerTime = "cellAnswerTime"
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text:String = "";
        var cellIdentifier:String = "";
        
       
        
        if (tableColumn == tableView.tableColumns[0]) {
            
            if (CallList.count > row)
            {
                let item = CallList[row];
                text = String(item.Id ?? 0);
            }

            cellIdentifier = CellIdentifiers.cellID;
        }else if (tableColumn == tableView.tableColumns[1]){
            if (CallList.count > row)
            {
                let item = CallList[row];
                text = item.AcceptedUser ?? "";
            }
            cellIdentifier = CellIdentifiers.cellAcceptedUser;
        }else if (tableColumn == tableView.tableColumns[2]){
            if (CallList.count > row)
            {
                let item = CallList[row];
                text = item.Room ?? "";
            }
            cellIdentifier = CellIdentifiers.cellRoom;
        }
        else if (tableColumn == tableView.tableColumns[3]){
            if (CallList.count > row)
            {
                let item = CallList[row];
                text = item.CallTime ?? "";
            }
            cellIdentifier = CellIdentifiers.cellCallTime;
        }
        else if (tableColumn == tableView.tableColumns[4]){
            if (CallList.count > row)
            {
                let item = CallList[row];
                text = item.AnswerTime ?? "";
            }
            cellIdentifier = CellIdentifiers.cellAnswerTime;
        }

        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as! NSTableCellView;
        cell.textField?.stringValue = text;
        
        
        return cell;
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
    
}




