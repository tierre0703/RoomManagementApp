/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`Call` represents a pending or active call.
*/

import Foundation
import SimplePushKit

class PushCall: Equatable, Identifiable {
    enum Status {
        case pending
        case active
    }
    
    public let id = UUID()
    var status: Status
    var participants: [User]
    
    init(status: Status, participants: [User]) {
        self.status = status
        self.participants = participants
    }
    
    static func == (lhs: PushCall, rhs: PushCall) -> Bool {
        lhs.id == rhs.id
    }
}
