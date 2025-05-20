//
//  StoryAvatarView.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import SwiftUI

struct StoryAvatarView: View {
    let user: User
    let state: UserStoryState
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: user.profilePictureURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if phase.error != nil {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.gray)
            } else {
                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(state.seen ? Color.gray : Color.blue, lineWidth: 2)
        )
    }
}

struct StoryAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = URL(string: "https://i.pravatar.cc/300?u=1") {
            StoryAvatarView(
                user: User(id: 1, name: "Neo", profilePictureURL: url),
                state: UserStoryState(userId: 1, seen: false, liked: false, lastViewedIndex: 0),
                size: 70
            )
        }
    }
}

#Preview {
    if let url = URL(string: "https://i.pravatar.cc/300?u=1") {
        StoryAvatarView(
            user: User(id: 1, name: "Neo", profilePictureURL: url),
            state: UserStoryState(userId: 1, seen: false, liked: false, lastViewedIndex: 0),
            size: 70
        )
    }}
