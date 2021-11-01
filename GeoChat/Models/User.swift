//
//  User.swift
//  GeoChat
//
//  Created by Nick Sagan on 01.11.2021.
//

import Foundation
import MessengerKit

struct User: MSGUser {
    var displayName: String
    
    var avatar: UIImage?
    
    var avatarUrl: URL?
    
    var isSender: Bool
    
}
