//
//  SplashView.swift
//  MaximusPrecision
//
//  Created by Pedro Carlos  Monzalvo Navarro on 11/04/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.92
    @State private var opacity = 0.6

    /// How long the splash stays up before transitioning. Tests skip it entirely.
    private let splashDuration: TimeInterval = 2.0

    var body: some View {
        Group {
            if isActive {
                QuoteFormView()
            } else {
                ZStack {
                    Color.black
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        Image("maximus_logo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                            .overlay(
                               Circle()
                                 .stroke(Color.white.opacity(0.15), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 8)
                            .scaleEffect(scale)
                            .opacity(opacity)
                    }
                }
                .accessibilityIdentifier(A11y.Splash.root)
                .onAppear(perform: startSplash)
            }
        }
    }

    private func startSplash() {
        // Under UI tests, skip straight to the form for fast, deterministic runs.
        guard !LaunchArgument.shouldSkipSplash else {
            isActive = true
            return
        }

        withAnimation(.easeInOut(duration: 1.0)) {
            scale = 1.0
            opacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
            withAnimation(.easeInOut(duration: 0.35)) {
                isActive = true
            }
        }
    }
}
