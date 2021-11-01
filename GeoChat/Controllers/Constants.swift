//
//  Constants.swift
//  GeoChat
//
//  Created by Nick Sagan on 01.11.2021.
//

struct K {
    static let appName = "GeoChat"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let registrationSegue = "RegistrationToTable"
    static let loginSegue = "LoginToTable"
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FBase {
        static let collectionName = "messages"
        static let userField = "user"
        static let messageID = "id"
        static var senderGeo = "geo"
        static let bodyField = "body"
        static let dateField = "date"
    }
}

