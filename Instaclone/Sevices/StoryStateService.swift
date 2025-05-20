//
//  StoryStateService.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation

protocol StoryStateServiceProtocol {
    func getStoryState(for userId: Int) -> UserStoryState
    func saveStoryState(_ state: UserStoryState)
    func markAsSeen(userId: Int)
    func toggleLike(userId: Int) -> Bool
    func updateLastViewedIndex(userId: Int, index: Int)
}

class StoryStateService: StoryStateServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let storyStatesKey = "storyStates"
    
    func getStoryState(for userId: Int) -> UserStoryState {
        let states = getAllStoryStates()
        
        return states.first(where: { $0.userId == userId }) ??
               UserStoryState(userId: userId, seen: false, liked: false, lastViewedIndex: 0)
    }
    
    func saveStoryState(_ state: UserStoryState) {
        var states = getAllStoryStates()
        
        if let index = states.firstIndex(where: { $0.userId == state.userId }) {
            states[index] = state
        } else {
            states.append(state)
        }
        
        saveAllStoryStates(states)
    }
    
    func markAsSeen(userId: Int) {
        var state = getStoryState(for: userId)
        state.seen = true
        saveStoryState(state)
    }
    
    func toggleLike(userId: Int) -> Bool {
        var state = getStoryState(for: userId)
        state.liked = !state.liked
        saveStoryState(state)
        
        return state.liked
    }
    
    func updateLastViewedIndex(userId: Int, index: Int) {
        var state = getStoryState(for: userId)
        state.lastViewedIndex = index
        saveStoryState(state)
    }
    
    private func getAllStoryStates() -> [UserStoryState] {
        guard let data = userDefaults.data(forKey: storyStatesKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([UserStoryState].self, from: data)
        } catch {
            print("Erreur lors du décodage des états: \(error)")
            return []
        }
    }
    
    private func saveAllStoryStates(_ states: [UserStoryState]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(states)
            userDefaults.set(data, forKey: storyStatesKey)
        } catch {
            print("Erreur lors de l'encodage des états: \(error)")
        }
    }
}
