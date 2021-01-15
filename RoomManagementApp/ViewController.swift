//
//  ViewController.swift
//  RoomManagementApp
//
//  Created by Tierre on 12/24/20.
//

import Cocoa

class ViewController: NSViewController {
   //MARK property
    @IBOutlet weak var btnEmailManagement: NSButton!
    @IBOutlet weak var btnRepeaterManagement: NSButton!
    @IBOutlet weak var btnActiveReceivers: NSButton!
    @IBOutlet weak var btnCallManagement: NSButton!
    @IBOutlet weak var btnRoomManagement: NSButton!
    @IBOutlet weak var btnUserManagement: NSButton!
    @IBOutlet weak var btnEmailConfiguration: NSButton!
    
    
    
    
    @IBOutlet weak var repeaterStatusView: NSView!
    
    @IBOutlet weak var UserMgntView: NSView!
    
    @IBOutlet weak var RoomMgntView: NSView!
    
    @IBOutlet weak var callMgntView: NSView!
    
    @IBOutlet weak var emailMgntView: NSView!
    
    @IBOutlet weak var mobileAppStatusView: NSView!
    @IBOutlet weak var emailConfigurationView: NSView!
    
    
    //MARK action
    @IBAction func onClickUserManagement(_ sender: Any) {
        clearView()
        selectBtn(btnId: 0)
    }

    @IBAction func onClickRoomManagement(_ sender: Any) {
        clearView()
        selectBtn(btnId: 1)
    }

    @IBAction func onClickCallManagement(_ sender: Any) {
        clearView()
        selectBtn(btnId: 2)
    }

    @IBAction func onActiveReceivers(_ sender: Any) {
        clearView()
        selectBtn(btnId: 3)
    }

    @IBAction func onClickRepeaterManagement(_ sender: Any) {
        clearView()
        selectBtn(btnId: 4)
    }

    @IBAction func onClickEmailManagement(_ sender: Any) {
        clearView()
        selectBtn(btnId: 5)
    }
    
    @IBAction func onClickEmailConfiguration(_ sender: Any) {
        clearView();
        selectBtn(btnId: 6);
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        clearView()
        btnUserManagement.state = NSButton.StateValue.on;
        UserMgntView.isHidden = false;
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func clearView()
    {
        btnUserManagement.state = NSButton.StateValue.off;
        btnRoomManagement.state = NSButton.StateValue.off;
        btnCallManagement.state = NSButton.StateValue.off;
        btnActiveReceivers.state = NSButton.StateValue.off;
        btnRepeaterManagement.state = NSButton.StateValue.off;
        btnEmailManagement.state = NSButton.StateValue.off;
        btnEmailConfiguration.state = NSButton.StateValue.off;
        
        UserMgntView.isHidden = true;
        RoomMgntView.isHidden = true;
        callMgntView.isHidden = true;
        emailMgntView.isHidden = true;
        mobileAppStatusView.isHidden = true;
        repeaterStatusView.isHidden = true;
        emailConfigurationView.isHidden = true;
    }
    
    
    func selectBtn(btnId: Int)
    {
        switch btnId
        {
        case 0:
            btnUserManagement.state = NSButton.StateValue.on;
            UserMgntView.isHidden = false
            break;
        case 1:
            btnRoomManagement.state = NSButton.StateValue.on;
            RoomMgntView.isHidden = false
            break;
        case 2:
            btnCallManagement.state = NSButton.StateValue.on;
            callMgntView.isHidden = false
            break;
        case 3:
            btnActiveReceivers.state = NSButton.StateValue.on;
            mobileAppStatusView.isHidden = false
            break;
        case 4:
            btnRepeaterManagement.state = NSButton.StateValue.on;
            repeaterStatusView.isHidden = false
                break;
        case 5:
            btnEmailManagement.state = NSButton.StateValue.on;
            emailMgntView.isHidden = false;
            break;
        case 6:
            btnEmailConfiguration.state = NSButton.StateValue.on;
            emailConfigurationView.isHidden = false;
            break;

        default:
            print("\n SelectTabButton Error");
        }
        
    }


}

