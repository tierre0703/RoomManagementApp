//
//  EmailReportSchedule.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/13/21.
//

import Foundation
import Cocoa
import PDFKit

class EmailReportSchedule {
    static var Instance = EmailReportSchedule()
    var timer:Timer?;
    var lastDateTime:Date?;
    var sent:Bool = false;
    
    
    func Start() {
        timer = Timer.scheduledTimer(timeInterval: 20.0, target:self, selector: #selector(OnTimedEvent), userInfo: nil, repeats: true)
    }
    
    func Stop() {
        guard timer != nil else { return; }
        timer?.invalidate()
        timer = nil;
    }
    
    func _timerEvent() {
        if lastDateTime == nil {
            sent = false;
        }
        else {
            let date = Date();
            let lastCalendar = Calendar.current.dateComponents([.day], from: lastDateTime!);
            let currentCalendar = Calendar.current.dateComponents([.day], from: date)
            let lastDay = lastCalendar.day;
            let today = lastCalendar.day;
            if(Int(lastDay ?? 0) < Int(today ?? 0)) {
                sent = false;
            }
            else
            {
                sent = true;
            }
            
            if(sent == false) {
                createReport()
                sent = true;
                
                lastDateTime = Date();
            }
        }
    }
    
    
    func createReport() {
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight );
        
        let date = Date();
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let creationTime = dateFormat.string(from: date)
        
        
        let pdfTitle = "Daily Report for the Steward Call System: " + creationTime;
        let pdfMetadata = [
            kCGPDFContextCreator: "Steward Call System",
            kCGPDFContextAuthor: "Steward Call System",
            kCGPDFContextTitle: "Daily Report for the Steward Call System"
        ];
        
        /**
                    * PDF Create
         */
        //create pdf
        print("\nEmailReportSchedule->createReport()");
        
        //sendAsync
        EmailNotification.Instance.SendAsync(subject: pdfTitle, body: ""	)
    }
    
    @objc func OnTimedEvent()
    {
        _timerEvent()
    }
    
    
}
