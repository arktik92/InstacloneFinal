//
//  StoriesService.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation

protocol StoriesServiceProtocol {
    func getStories(page: Int) async throws -> [(user: User, story: Story, state: UserStoryState)]
    func markAsSeen(userId: Int)
    func toggleLike(userId: Int) -> Bool
    func updateLastViewedIndex(userId: Int, index: Int)
    func isStoryLiked(userId: Int) -> Bool
}

class StoriesService: StoriesServiceProtocol {
    private let webService: WebServiceProtocol
    private let storyStateService: StoryStateServiceProtocol
    
    init(webService: WebServiceProtocol = WebService(),
         storyStateService: StoryStateServiceProtocol = StoryStateService()) {
        self.webService = webService
        self.storyStateService = storyStateService
    }
    
    func getStories(page: Int) async throws -> [(user: User, story: Story, state: UserStoryState)] {
        let users = try await webService.getUsers(page: page)
        
        var result: [(user: User, story: Story, state: UserStoryState)] = []
        
        for user in users {
            let imageURLs = try await webService.getStoryImages(for: user.id)
            let story = Story(userId: user.id, imageURLs: imageURLs)
            let state = storyStateService.getStoryState(for: user.id)
            
            result.append((user: user, story: story, state: state))
        }
        
        return result
    }
    
    func markAsSeen(userId: Int) {
        storyStateService.markAsSeen(userId: userId)
    }
    
    func toggleLike(userId: Int) -> Bool {
        return storyStateService.toggleLike(userId: userId)
    }
    
    func updateLastViewedIndex(userId: Int, index: Int) {
        storyStateService.updateLastViewedIndex(userId: userId, index: index)
    }
    
    func isStoryLiked(userId: Int) -> Bool {
        return storyStateService.getStoryState(for: userId).liked
    }
}
