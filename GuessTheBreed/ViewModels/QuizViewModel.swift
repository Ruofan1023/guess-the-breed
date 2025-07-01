//
//  QuizViewModel.swift
//  GuessTheBreed
//
//  Created by Wang Ruofan(Ruofan.W) on 30/6/25.
//

import Foundation

@MainActor
final class QuizViewModel: ObservableObject {
    @Published private(set) var imageURL: URL?
    @Published private(set) var options: [String] = []
    @Published private(set) var correctAnswer: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var showResult: Bool = false
    @Published private(set) var userGotItRight: Bool = false

    private let service: DogAPIServiceProtocol
    private var breeds: [String]? = nil

    init(service: DogAPIServiceProtocol) {
        self.service = service
    }

    private func loadBreedsIfNeeded() async -> [String]? {
        if let breeds = breeds {
            return breeds
        }
        guard case let .success(fetchedBreeds) = await service.fetchBreedsList(),
              fetchedBreeds.count >= 4 else {
            return nil
        }
        self.breeds = fetchedBreeds
        return fetchedBreeds
    }

    func loadNewQuestion() async {
        isLoading = true
        defer { isLoading = false }

        guard let breeds = await loadBreedsIfNeeded(), breeds.count >= 4 else {
            options = []
            imageURL = nil
            return
        }

        let correct = breeds.randomElement()!
        var quizOptions = Set([correct])

        while quizOptions.count < 4 {
            quizOptions.insert(breeds.randomElement()!)
        }

        guard case let .success(url) = await service.fetchRandomImage(for: correct) else {
            options = []
            imageURL = nil
            return
        }

        correctAnswer = correct
        options = quizOptions.shuffled()
        imageURL = url
        showResult = false
    }

    func userSelected(_ answer: String) {
        userGotItRight = (answer == correctAnswer)
        showResult = true
    }
}
