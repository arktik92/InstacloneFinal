//
//  UserStoryState.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation

struct UserStoryState: Codable {
    let userId: Int
    var seen:  Bool
    var liked: Bool
    var lastViewedIndex: Int
}
