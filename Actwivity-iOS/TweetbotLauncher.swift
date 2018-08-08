//
//  TweetbotLauncher.swift
//  Actwivity-iOS
//
//  Created by Tommy Yang on 7/24/18.
//  Copyright © 2018 tOmMyanG. All rights reserved.
//

import Foundation
import os.log
import UIKit

class TweetbotLauncher: TwitterClientLauncherProtocol {
    static let clientProtocol = "tweetbot://"
    static func openToStatus(id statusID: String, from screenname: String) {
        guard let statusURL = URL(string: "\(clientProtocol)\(screenname)/status/\(statusID)") else {
            os_log(.error, "Failed to generate URL")
            return
        }
        self.openURL(url: statusURL)
    }

    static func openToProfile(of profileScreenname: String, from screenname: String) {
        guard let profileURL = URL(string: "\(clientProtocol)\(screenname)/user_profile/\(profileScreenname)") else {
            os_log(.error, "Failed to generate URL")
            return
        }
        self.openURL(url: profileURL)
    }

    static func openToDirectMessagesScreen(of screenname: String) {
        guard let DMSURL = URL(string: "\(clientProtocol)\(screenname)/direct_messages") else {
            os_log(.error, "Failed to generate URL")
            return
        }
        self.openURL(url: DMSURL)
    }

    static func openURL(url: URL) {
        os_log(.info, "Opening %@", url.absoluteString)
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
