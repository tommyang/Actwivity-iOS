//
//  TwitterClientLauncherProtocol.swift
//  Actwivity-iOS
//
//  Created by Tommy Yang on 7/24/18.
//  Copyright © 2018 tOmMyanG. All rights reserved.
//

import Foundation

protocol TwitterClientLauncherProtocol {
    static func openToStatus(id statusID: String, from screenname: String)
    static func openToProfile(of profileScreenname: String, from screenname: String)
    static func openToDirectMessagesScreen(of screenname: String)
}
