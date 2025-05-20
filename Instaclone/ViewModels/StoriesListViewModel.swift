//
//  StoriesListViewModel.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation
import Combine

class StoriesListViewModel: ObservableObject {
    @Published var storyItems: [(user: User, story: Story, state: UserStoryState)] = []
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var currentPage = 1
    
    private let storiesService: StoriesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var loadedUserIds = Set<Int>()
    
    init(storiesService: StoriesServiceProtocol = StoriesService()) {
        self.storiesService = storiesService
    }
    
    @MainActor
    func loadStories() async {
        if isLoading { return }
        
        isLoading = true
        hasError = false
        
        do {
            let newStories = try await storiesService.getStories(page: currentPage)
            
            let uniqueNewStories = newStories.filter { item in
                !loadedUserIds.contains(item.user.id)
            }
            
            for item in uniqueNewStories {
                loadedUserIds.insert(item.user.id)
            }
            
            storyItems.append(contentsOf: uniqueNewStories)
            currentPage += 1
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func refreshStories() async {
        storyItems = []
        loadedUserIds.removeAll()
        currentPage = 1
        await loadStories()
    }
    
    func loadMoreIfNeeded(currentItem: User) {
        let thresholdIndex = storyItems.firstIndex { $0.user.id == currentItem.id } ?? 0
        let shouldLoadMore = thresholdIndex >= storyItems.count - 3
        
        if shouldLoadMore && !isLoading {
            Task {
                await loadStories()
            }
        }
    }
}
