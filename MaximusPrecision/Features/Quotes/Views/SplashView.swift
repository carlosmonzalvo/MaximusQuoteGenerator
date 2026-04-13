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
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        scale = 1.0
                        opacity = 1.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}
