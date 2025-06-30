//
//  DogAPIService.swift
//  GuessTheBreed
//
//  Created by Wang Ruofan(Ruofan.W) on 30/6/25.
//

import Foundation

protocol DogAPIServiceProtocol {
    func fetchBreedsList() async -> Result<[String], ServiceError>
    func fetchRandomImage(for breed: String) async -> Result<URL, ServiceError>
}

enum ServiceError: Error {
    case networkError
    case invalidBreedFormat
}

struct BreedsListResponse: Decodable {
    let message: [String: [String]]
    let status: String
}

struct BreedImageResponse: Decodable {
    let message: String
    let status: String
}

enum Breeds {}

class DogAPIService: DogAPIServiceProtocol {
    static let shared = DogAPIService()
    
    private let network: NetworkProtocol
    private let baseURLStr: String = "https://dog.ceo"

    init(network: NetworkProtocol = Network.shared) {
        self.network = network
    }
    
    func fetchBreedsList() async -> Result<[String], ServiceError> {
        let url = URL(string: "\(baseURLStr)/api/breeds/list/all")!
        let response: Result<BreedsListResponse, NetworkError> = await network.fetch(from: url)
        
        guard let breedsResponse = try? response.get() else {
            return .failure(.networkError)
        }

        let flattenedBreeds = breedsResponse.message.flatMap { breed, subBreeds -> [String] in
            if subBreeds.isEmpty {
                return [breed]
            } else {
                return subBreeds.map { "\(breed) \($0)" }
            }
        }

        return .success(flattenedBreeds)
    }

    func fetchRandomImage(for breed: String) async -> Result<URL, ServiceError> {
        
        guard let url = imageURL(for: breed) else {
            return .failure(.invalidBreedFormat)
        }
        
        let response: Result<BreedImageResponse, NetworkError> = await network.fetch(from: url)
        
        guard let imageResponse = try? response.get(),
              let imageURL = URL(string: imageResponse.message) else {
            return .failure(.networkError)
        }
        
        return .success(imageURL)
    }
    
    private func imageURL(for breed: String) -> URL? {
        let components = breed.lowercased().split(separator: " ")
        
        let urlString: String
        
        if components.count == 1 {
            urlString = "\(baseURLStr)/api/breed/\(components[0])/images/random"
        } else if components.count == 2 {
            urlString = "\(baseURLStr)/api/breed/\(components[0])/\(components[1])/images/random"
        } else {
            return nil
        }
        
        return URL(string: urlString)
    }
}
