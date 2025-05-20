//
//  Story.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation

struct Story: Identifiable {
    let id = UUID()
    let userId: Int
    let imageURLs: [URL]
    var currentIndex: Int = 0
    let createdAt: Date = Date()
    
    var currentImageURL: URL? {
        guard imageURLs.indices.contains(currentIndex) else {
            return nil
        }
        return imageURLs[currentIndex]
    }
}
