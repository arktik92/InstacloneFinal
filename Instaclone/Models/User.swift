//
//  User.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation
import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let profilePictureURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePictureURL = "profile_picture_url"
    }
}

struct UsersResponse: Codable {
    let pages: [Page]
    
    struct Page: Codable {
        let users: [User]
    }
}
