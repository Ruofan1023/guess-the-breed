//
//  DogAPIServiceTests.swift
//  GuessTheBreed
//
//  Created by Wang Ruofan(Ruofan.W) on 30/6/25.
//

import XCTest
@testable import GuessTheBreed

final class DogAPIServiceTests: XCTestCase {
    
    var mockNetwork: MockNetwork!
    var service: DogAPIService!
    
    override func setUp() {
        super.setUp()
        mockNetwork = MockNetwork()
        service = DogAPIService(network: mockNetwork)
    }
    
    func testFetchBreedsList_Success() async throws {
        // Given
        let json = """
        {
            "message": {
                "bulldog": ["english", "french"],
                "poodle": []
            },
            "status": "success"
        }
        """.data(using: .utf8)!
        
        mockNetwork.responseData = json
        
        // When
        let result = await service.fetchBreedsList()
        
        // Then
        switch result {
        case .success(let breeds):
            XCTAssertEqual(breeds.sorted(), ["bulldog english", "bulldog french", "poodle"].sorted())
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }
    
    func testFetchBreedsList_Failure() async throws {
        // Given
        mockNetwork.shouldFail = true
        
        // When
        let result = await service.fetchBreedsList()
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            XCTAssertEqual(error, .networkError)
        }
    }
    
    func testFetchBreedsList_MalformedJSON() async throws {
        // Given
        let malformedJSON = """
        {
            "message": "this should be a dictionary",
            "status": "success"
        }
        """.data(using: .utf8)!
        
        mockNetwork.responseData = malformedJSON
        
        // When
        let result = await service.fetchBreedsList()
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure due to malformed JSON, got success")
        case .failure(let error):
            XCTAssertEqual(error, .networkError)
        }
    }

}


final class MockNetwork: NetworkProtocol {
    
    var responseData: Data?
    var shouldFail: Bool = false
    
    func fetch<T: Decodable>(from url: URL) async -> Result<T, NetworkError> {
        if shouldFail {
            return .failure(.badServerResponse)
        }
        
        guard let data = responseData else {
            return .failure(.unknown)
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(.decodingFailed)
        }
    }
}
