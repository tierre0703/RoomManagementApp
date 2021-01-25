//
//  PacketCodes.swift
//  RoomManagementApp
//
//  Created by Tierre on 1/19/21.
//

import Foundation

enum PKT_CODE {
    static let PKT_PING = 500
    static let PKT_ACK = 501
    static let PKT_CONNECTION_ESTABLISHED = 502
    static let PKT_AUTH = 503
    static let PKT_DETAIL = 504
    static let PKT_CANCELLED = 505
    static let PKT_ACCEPTED = 506
    static let PKT_REJECTED = 507
    static let PKT_NOT_AUTH = 508
    static let PKT_APPROVED = 509
}
