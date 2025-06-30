//
//  QuizView.swift
//  GuessTheBreed
//
//  Created by Wang Ruofan(Ruofan.W) on 30/6/25.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel(service: DogAPIService())

    var body: some View {
        ZStack {
            if viewModel.showResult {
                ResultOverlay(
                    isSuccess: viewModel.userGotItRight,
                    correctBreed: viewModel.correctAnswer
                ) {
                    Task {
                        await viewModel.loadNewQuestion()
                    }
                }
                .zIndex(100)
            }

            VStack(spacing: 20) {
                Spacer()

                if let imageURL = viewModel.imageURL {
                    ImageView(imageURL: imageURL)
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(height: 250)
                } else {
                    Text("Unable to load image.")
                }

                Spacer()

                ForEach(viewModel.options, id: \.self) { option in
                    Button {
                        viewModel.userSelected(option)
                    } label: {
                        Text(option.capitalized)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.showResult)
                }

                Spacer()
            }
        }

        .padding()
        .onAppear {
            Task {
                await viewModel.loadNewQuestion()
            }
        }
    }
}

// #Preview {
//    QuizView()
// }
