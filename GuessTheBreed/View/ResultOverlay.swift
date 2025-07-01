//
//  SuccessOverlay.swift
//  GuessTheBreed
//
//  Created by Wang Ruofan(Ruofan.W) on 30/6/25.
//
import SwiftUI

struct ResultOverlay: View {
    @State private var scale = 0.1
    let onContinue: () -> Void
    private var isSuccess: Bool
    private var correctBreed: String

    init(isSuccess: Bool, correctBreed: String, onContinue: @escaping () -> Void) {
        self.isSuccess = isSuccess
        self.correctBreed = correctBreed
        self.onContinue = onContinue
    }

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            VStack(spacing: 24) {
                if isSuccess {
                    ZStack {
                        Circle()
                            .fill(Color.green.gradient)
                            .frame(width: 120, height: 120)

                        Text("🎉")
                            .font(.system(size: 50))
                    }

                    VStack(spacing: 8) {
                        Text("Correct!")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)

                        Text("It's a \(correctBreed). Great job!")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.red.gradient)
                            .frame(width: 120, height: 120)

                        Text("😢")
                            .font(.system(size: 50))
                    }

                    VStack(spacing: 8) {
                        Text("It's wrong.")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)

                        Text("It's a \(correctBreed). Try again!")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: onContinue) {
                    Text("Next Question")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue.gradient)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .scaleEffect(scale)
            .animation(.spring, value: scale)
        }
        .onAppear {
            scale = 1.0
        }
    }
}

// #Preview {
//    SuccessOverlay {
//
//    }
// }
