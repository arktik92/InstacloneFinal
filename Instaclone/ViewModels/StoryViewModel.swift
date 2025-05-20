//
//  StoryViewModel.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation
import Combine

class StoryViewModel: ObservableObject {
    @Published var story: Story
    @Published var user: User
    @Published var state: UserStoryState
    @Published var progress: Float = 0
    @Published var isPlaying: Bool = true
    @Published var shouldMoveToNextUser: Bool = false
    @Published var isLiked: Bool = false
    
    private let storyDuration: TimeInterval = 5.0
    private var timer: Timer?
    private let storiesService: StoriesServiceProtocol
    
    init(user: User, story: Story, state: UserStoryState, storiesService: StoriesServiceProtocol = StoriesService()) {
        self.user = user
        self.story = story
        self.state = state
        self.storiesService = storiesService
        self.isLiked = state.liked
        
        self.story.currentIndex = state.lastViewedIndex
    }
    
    func startTimer() {
        stopTimer()
        
        progress = 0
        isPlaying = true
        
        storiesService.markAsSeen(userId: user.id)
        state.seen = true
        
        storiesService.updateLastViewedIndex(userId: user.id, index: story.currentIndex)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            let increment = Float(0.05 / self.storyDuration)
            let newProgress = self.progress + increment
            
            if newProgress <= 1.0 {
                self.progress = newProgress
            } else {
                self.progress = 1.0
                self.stopTimer()
                self.handleNextStory()
            }
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
    }
    
    private func handleNextStory() {
        if story.currentIndex < story.imageURLs.count - 1 {
            story.currentIndex += 1
            startTimer()
        } else {
            shouldMoveToNextUser = true
        }
    }
    
    func previousStory() {
        if story.currentIndex > 0 {
            story.currentIndex -= 1
            startTimer()
        } else {
            stopTimer()
            shouldMoveToNextUser = true
        }
    }
    
    func nextStory() {
        stopTimer()
        handleNextStory()
    }
    
    func toggleLike() {
        let newLikedState = storiesService.toggleLike(userId: user.id)
        
        state.liked = newLikedState
        isLiked = newLikedState
    }
    
    func resetShouldMoveToNextUser() {
        shouldMoveToNextUser = false
    }
    
    func refreshLikeState() {
        let currentLikeState = storiesService.isStoryLiked(userId: user.id)
        isLiked = currentLikeState
        state.liked = currentLikeState
    }
    
    deinit {
        stopTimer()
    }
}
