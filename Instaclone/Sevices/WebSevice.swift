//
//  WebSevice.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//

import Foundation
import Alamofire

protocol WebServiceProtocol {
    func getUsers(page: Int) async throws -> [User]
    func getStoryImages(for userId: Int) async throws -> [URL]
}

class WebService: WebServiceProtocol {
    private let baseImageURL = "https://picsum.photos/400/800?random="
    
    func getUsers(page: Int) async throws -> [User] {
        guard let url = Bundle.main.url(forResource: "users", withExtension: "json") else {
            throw NetworkError.resourceNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let usersResponse = try decoder.decode(UsersResponse.self, from: data)
            
            let pageIndex = (page - 1) % usersResponse.pages.count
            return usersResponse.pages[pageIndex].users
        } catch {
            print("Erreur de décodage: \(error)")
            throw error
        }
    }
    
    func getStoryImages(for userId: Int) async throws -> [URL] {
        let count = Int.random(in: 1...5)
        
        return try await withCheckedThrowingContinuation { continuation in
            var urls: [URL] = []
            let dispatchGroup = DispatchGroup()
            
            for i in 0..<count {
                dispatchGroup.enter()
                
                let seed = "\(userId)_\(i)"
                let imageUrl = "\(baseImageURL)\(seed.hashValue)"
                
                AF.request(imageUrl, method: .head)
                    .response { response in
                        if let url = response.request?.url {
                            urls.append(url)
                        }
                        dispatchGroup.leave()
                    }
            }
            
            dispatchGroup.notify(queue: .main) {
                continuation.resume(returning: urls)
            }
        }
    }
    
    func getStoryImagesFromAPI(for userId: Int) async throws -> [URL] {
        let accessKey = "LwN5hLnTsjIVgSuHUsd2XBbBgD768zF2nqsX63N6bZE"
        let count = Int.random(in: 1...5)
        
        return try await withCheckedThrowingContinuation { continuation in
            let url = "https://api.unsplash.com/photos/random?count=\(count)"
            
            AF.request(url, headers: ["Authorization": "Client-ID \(accessKey)"])
                .validate()
                .responseDecodable(of: [UnsplashPhoto].self) { response in
                    switch response.result {
                    case .success(let photos):
                        let urls = photos.compactMap { URL(string: $0.urls.regular) }
                        continuation.resume(returning: urls)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

struct UnsplashPhoto: Codable {
    let id: String
    let urls: UnsplashPhotoURLs
}

struct UnsplashPhotoURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

enum NetworkError: Error {
    case resourceNotFound
    case invalidData
    case apiError(String)
}
