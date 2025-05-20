//
//  FeedPostView.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import SwiftUI

import SwiftUI

struct FeedPostView: View {
    let post: FeedPost
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: post.userProfileImageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                
                Text(post.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            
            AsyncImage(url: post.imageURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } else if phase.error != nil {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                }
            }
            
            HStack(spacing: 16) {
                Button {
                    isLiked.toggle()
                } label: {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(isLiked ? .red : .primary)
                }
                
                Button {
                } label: {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                
                Button {
                } label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button {
                } label: {
                    Image(systemName: "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            
            Text("\(post.likeCount + (isLiked ? 1 : 0)) likes")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            HStack(alignment: .top) {
                Text(post.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(post.caption)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
            if post.commentCount > 0 {
                Text("Voir les \(post.commentCount) commentaires")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            Text(formatDate(post.timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            isLiked = Bool.random()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Aujourd'hui à \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Hier"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM"
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: date)
        }
    }
}

#Preview {
    if let profileURL = URL(string: "https://i.pravatar.cc/300?u=1"),
       let imageURL = URL(string: "https://picsum.photos/800/800?random=42") {
        return FeedPostView(
            post: FeedPost(
                userId: 1,
                username: "Neo",
                userProfileImageURL: profileURL,
                imageURL: imageURL,
                caption: "Belle journée aujourd'hui ! ☀️ #nofilter #matrix",
                likeCount: 123,
                commentCount: 42,
                timestamp: Date().addingTimeInterval(-3600)
            )
        )
    } else {
        return Text("Erreur de prévisualisation")
    }
}
