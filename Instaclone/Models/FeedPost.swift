//
//  FeedPost.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation

struct FeedPost: Identifiable, Equatable {
    let id: UUID = UUID()
    let userId: Int
    let username: String
    let userProfileImageURL: URL
    let imageURL: URL
    let caption: String
    let likeCount: Int
    let commentCount: Int
    let timestamp: Date
    
    static func generateMockPosts(for users: [User], count: Int = 10) -> [FeedPost] {
        var posts: [FeedPost] = []
        
        let captions = [
            "Belle journée aujourd'hui ! ☀️",
            "Moment parfait #nofilter",
            "Nouvelle aventure ! 🚀",
            "La vie est belle 🌈",
            "Souvenirs inoubliables ❤️",
            "Juste un moment de détente 🧘‍♂️",
            "Nouvelle création ! Qu'en pensez-vous ? 🎨",
            "Explorer de nouveaux horizons 🌍",
            "Moment de paix ✨",
            "C'est la saison ! 🌟"
        ]
        
        for i in 0..<count {
            let userIndex = i % users.count
            let user = users[userIndex]
            
            let seed = "\(user.id)_post_\(i)"
            let seedHash = abs(seed.hashValue)
            guard let imageURL = URL(string: "https://picsum.photos/800/800?random=\(seedHash)") else {
                continue
            }
            
            let caption = captions[i % captions.count]
            
            let likeCount = Int.random(in: 5...500)
            let commentCount = Int.random(in: 0...50)
            
            let timeInterval = TimeInterval(-Double(Int.random(in: 0...(7*24*60*60))))
            let timestamp = Date().addingTimeInterval(timeInterval)
            
            let post = FeedPost(
                userId: user.id,
                username: user.name,
                userProfileImageURL: user.profilePictureURL,
                imageURL: imageURL,
                caption: caption,
                likeCount: likeCount,
                commentCount: commentCount,
                timestamp: timestamp
            )
            
            posts.append(post)
        }
        
        return posts.sorted { $0.timestamp > $1.timestamp }
    }
}
