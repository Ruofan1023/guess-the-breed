//
//  QuizViewModelTests.swift
//  GuessTheBreed
//
//  Created by Nafour on 1/7/25.
//

import XCTest
@testable import GuessTheBreed

@MainActor
final class QuizViewModelTests: XCTestCase {
    var viewModel: QuizViewModel!
    var mockService: MockDogAPIService!
    
    override func setUp() {
        super.setUp()
        mockService = MockDogAPIService()
        viewModel = QuizViewModel(service: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.imageURL)
        XCTAssertTrue(viewModel.options.isEmpty)
        XCTAssertEqual(viewModel.correctAnswer, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showResult)
        XCTAssertFalse(viewModel.userGotItRight)
    }
    
    func testLoadNewQuestionSuccess() async {
        mockService.breedsResult = .success(["breed1", "breed2", "breed3", "breed4", "breed5"])
        mockService.imageResult = .success(URL(string: "https://example.com/image.jpg")!)
        
        await viewModel.loadNewQuestion()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.imageURL)
        XCTAssertEqual(viewModel.options.count, 4)
        XCTAssertFalse(viewModel.correctAnswer.isEmpty)
        XCTAssertTrue(viewModel.options.contains(viewModel.correctAnswer))
        XCTAssertFalse(viewModel.showResult)
    }
    
    func testLoadNewQuestionWithInsufficientBreeds() async {
        mockService.breedsResult = .success(["breed1", "breed2"])
        
        await viewModel.loadNewQuestion()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.imageURL)
        XCTAssertTrue(viewModel.options.isEmpty)
    }
    
    func testLoadNewQuestionWithBreedsFailure() async {
        mockService.breedsResult = .failure(.networkError)
        
        await viewModel.loadNewQuestion()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.imageURL)
        XCTAssertTrue(viewModel.options.isEmpty)
    }
    
    func testLoadNewQuestionWithImageFailure() async {
        mockService.breedsResult = .success(["breed1", "breed2", "breed3", "breed4"])
        mockService.imageResult = .failure(.networkError)
        
        await viewModel.loadNewQuestion()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.imageURL)
        XCTAssertTrue(viewModel.options.isEmpty)
    }
    
    func testLoadingState() async {
        mockService.breedsResult = .success(["breed1", "breed2", "breed3", "breed4"])
        mockService.imageResult = .success(URL(string: "https://example.com/image.jpg")!)
        mockService.shouldDelay = true
        
        let loadTask = Task {
            await viewModel.loadNewQuestion()
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.isLoading)
        
        await loadTask.value
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testUserSelectedCorrectAnswer() async {
        mockService.breedsResult = .success(["breed1", "breed2", "breed3", "breed4"])
        mockService.imageResult = .success(URL(string: "https://example.com/image.jpg")!)
        
        await viewModel.loadNewQuestion()
        let correctAnswer = viewModel.correctAnswer
        
        viewModel.userSelected(correctAnswer)
        
        XCTAssertTrue(viewModel.userGotItRight)
        XCTAssertTrue(viewModel.showResult)
    }
    
    func testUserSelectedWrongAnswer() async {
        mockService.breedsResult = .success(["breed1", "breed2", "breed3", "breed4"])
        mockService.imageResult = .success(URL(string: "https://example.com/image.jpg")!)
        
        await viewModel.loadNewQuestion()
        let wrongAnswer = viewModel.options.first { $0 != viewModel.correctAnswer }!
        
        viewModel.userSelected(wrongAnswer)
        
        XCTAssertFalse(viewModel.userGotItRight)
        XCTAssertTrue(viewModel.showResult)
    }
    
    func testBreedsCache() async {
        mockService.breedsResult = .success(["breed1", "breed2", "breed3", "breed4"])
        mockService.imageResult = .success(URL(string: "https://example.com/image.jpg")!)
        
        await viewModel.loadNewQuestion()
        XCTAssertEqual(mockService.fetchBreedsCallCount, 1)
        
        await viewModel.loadNewQuestion()
        XCTAssertEqual(mockService.fetchBreedsCallCount, 1)
    }
    
    func testOptionsAreShuffled() async {
        mockService.breedsResult = .success(["a", "b", "c", "d", "e"])
        mockService.imageResult = .success(URL(string: "https://example.com/image.jpg")!)
        
        var optionSets: Set<String> = []
        
        for _ in 0..<10 {
            await viewModel.loadNewQuestion()
            optionSets.insert(viewModel.options[0])
        }
        
        XCTAssertGreaterThan(optionSets.count, 1)
    }
}

class MockDogAPIService: DogAPIServiceProtocol {
    var breedsResult: Result<[String], GuessTheBreed.ServiceError> = .success([])
    var imageResult: Result<URL, GuessTheBreed.ServiceError> = .success(URL(string: "https://dog.ceo/api/breed/hound/images/random")!)
    var fetchBreedsCallCount = 0
    var fetchImageCallCount = 0
    var shouldDelay = false
    
    func fetchBreedsList() async -> Result<[String], GuessTheBreed.ServiceError> {
        fetchBreedsCallCount += 1
        if shouldDelay {
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        return breedsResult
    }
    
    func fetchRandomImage(for breed: String) async -> Result<URL, GuessTheBreed.ServiceError> {
        fetchImageCallCount += 1
        if shouldDelay {
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        return imageResult
    }
}

