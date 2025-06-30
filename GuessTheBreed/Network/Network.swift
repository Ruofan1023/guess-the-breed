//
//  Network.swift
//  GuessTheBreed
//
//  Created by Wang Ruofan(Ruofan.W) on 30/6/25.
//

import Foundation

protocol NetworkProtocol {
    func fetch<T: Decodable>(from url: URL) async -> Result<T, NetworkError>
}

enum NetworkError: Error {
    case unknown
    case decodingFailed
    case badServerResponse
}

final class Network: NetworkProtocol {
    
    static let shared = Network()
    
    func fetch<T: Decodable>(from url: URL) async -> Result<T, NetworkError> {
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                return .failure(.badServerResponse)
            }
            
            let decodedData = try? JSONDecoder().decode(T.self, from: data)
            guard let decodedData else {
                return .failure(.decodingFailed)
            }

            return .success(decodedData)
            
        } catch {
            return .failure(.unknown)
        }
    }
}
