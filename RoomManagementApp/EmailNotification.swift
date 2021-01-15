//
//  EmailNotification.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/13/21.
//

import Foundation
import Cocoa
import SwiftSMTP

class EmailNotification {
    static var Instance = EmailNotification();
    
    func SendAsync(subject: String, body: String){

        //let auth = AuthMethod.login;
        
        if(EmailSettings.Instance.SMTP_HOST == "" || EmailSettings.Instance.USERNAME == "" || EmailSettings.Instance.PASSWORD == ""){
            return;
        }
        let client = SMTP.init(hostname: EmailSettings.Instance.SMTP_HOST, email: EmailSettings.Instance.USERNAME, password: EmailSettings.Instance.PASSWORD, port: Int32(EmailSettings.Instance.PORT), tlsMode: .ignoreTLS, tlsConfiguration: nil, authMethods: [], domainName: "localhost", timeout: 10);
        /*
        let client = SMTP(hostname: EmailSettings.Instance.SMTP_HOST, email: EmailSettings.Instance.USERNAME, password: EmailSettings.Instance.PASSWORD);
         */
        
        let fromAddress = Mail.User(name: EmailSettings.Instance.DISPLAY_NAME, email: EmailSettings.Instance.FROM_ADDRESS);
        
        var emails:[Mail.User] = [];
        for item in EmailFactory.Instance.GetAll() {
            let to_email = item.value;
            emails.append(Mail.User(email: to_email))
        }
        
        
        let mail = Mail(from: fromAddress, to: emails, subject: subject, text: body);
        
        client.send(mail, completion: { (failed) in
            print("\n Mail Sent Error", failed.debugDescription);
        })
     

    }
    
    func SendAsync(subject: String, body: String, data:Data){

        //let auth = AuthMethod.login;
        
        if(EmailSettings.Instance.SMTP_HOST == "" || EmailSettings.Instance.USERNAME == "" || EmailSettings.Instance.PASSWORD == ""){
            return;
        }
        let client = SMTP.init(hostname: EmailSettings.Instance.SMTP_HOST, email: EmailSettings.Instance.USERNAME, password: EmailSettings.Instance.PASSWORD, port: Int32(EmailSettings.Instance.PORT), tlsMode: .ignoreTLS, tlsConfiguration: nil, authMethods: [], domainName: "localhost", timeout: 10);
        /*
        let client = SMTP(hostname: EmailSettings.Instance.SMTP_HOST, email: EmailSettings.Instance.USERNAME, password: EmailSettings.Instance.PASSWORD);
         */
        
        let fromAddress = Mail.User(name: EmailSettings.Instance.DISPLAY_NAME, email: EmailSettings.Instance.FROM_ADDRESS);
        
        var emails:[Mail.User] = [];
        for item in EmailFactory.Instance.GetAll() {
            let to_email = item.value;
            emails.append(Mail.User(email: to_email))
        }
        
        
        let dataAttachment = Attachment(data: data, mime: "application/pdf", name: "Attachment.pdf")
        
        
        
        let mail = Mail(from: fromAddress, to: emails, subject: subject, text: body, attachments: [dataAttachment]);
        client.send(mail);
     

    }
}
