//
//  StoriesListView.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import SwiftUI

struct StoriesListView: View {
    @StateObject var viewModel = StoriesListViewModel()
    @State private var selectedStoryIndex: Int? = nil
    @State private var feedPosts: [FeedPost] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.storyItems.indices, id: \.self) { index in
                            let item = viewModel.storyItems[index]
                            Button {
                                selectedStoryIndex = index
                            } label: {
                                VStack {
                                    StoryAvatarView(
                                        user: item.user,
                                        state: item.state,
                                        size: 70
                                    )
                                    
                                    Text(item.user.name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                            }
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentItem: item.user)
                            }
                            .id("story_\(index)_\(item.user.id)")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .padding(.top, 4)
                
                
                Divider()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(feedPosts) { post in
                            FeedPostView(post: post)
                            
                            Divider()
                                .padding(.vertical, 8)
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if viewModel.hasError {
                            Text("Erreur: \(viewModel.errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                
            }
            .navigationTitle("Instaclone")
            .onAppear {
                Task {
                    await viewModel.loadStories()
                    
                    if !viewModel.storyItems.isEmpty {
                        let users = viewModel.storyItems.map { $0.user }
                        feedPosts = FeedPost.generateMockPosts(for: users)
                    }
                }
            }
            .refreshable {
                await viewModel.refreshStories()
                
                if !viewModel.storyItems.isEmpty {
                    let users = viewModel.storyItems.map { $0.user }
                    feedPosts = FeedPost.generateMockPosts(for: users)
                }
            }
            .fullScreenCover(item: $selectedStoryIndex) { index in
                let item = viewModel.storyItems[index]
                StoryView(
                    viewModel: StoryViewModel(
                        user: item.user,
                        story: item.story,
                        state: item.state
                    ),
                    storyItems: viewModel.storyItems,
                    currentIndex: index,
                    isPresented: Binding<Bool>(
                        get: { selectedStoryIndex != nil },
                        set: { if !$0 { selectedStoryIndex = nil } }
                    )
                )
            }
        }
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}

#Preview {
    StoriesListView()
}
