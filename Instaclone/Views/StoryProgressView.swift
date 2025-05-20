//
//  StoryProgressView.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import SwiftUI

struct StoryProgressView: View {
    let totalStories: Int
    let currentIndex: Int
    let progress: Float
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<totalStories, id: \.self) { index in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(height: 2)
                    
                    if index < currentIndex {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(height: 2)
                    }
                    else if index == currentIndex {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(
                                width: max(0, min(UIScreen.main.bounds.width / CGFloat(totalStories) - 4, CGFloat(progress) * UIScreen.main.bounds.width / CGFloat(totalStories) - 4)),
                                height: 2
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }
}

#Preview {
    StoryProgressView(totalStories: 5, currentIndex: 2, progress: 0.5)
        .previewLayout(.sizeThatFits)
        .background(Color.black)
}
