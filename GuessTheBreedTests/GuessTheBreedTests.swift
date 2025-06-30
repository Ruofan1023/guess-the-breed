//
//  GuessTheBreedTests.swift
//  GuessTheBreedTests
//
//  Created by Wang Ruofan(Ruofan.W) on 30/6/25.
//

import Testing
@testable import GuessTheBreed

struct GuessTheBreedTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let result = await DogAPIService().fetchRandomImage(for: "african")
        print(result)
    }

}
