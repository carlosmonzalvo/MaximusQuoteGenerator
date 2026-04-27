//
//  UIApplication+Extensions.swift
//  MaximusPrecision
//
//  Created by Pedro Carlos  Monzalvo Navarro on 03/04/26.
//

import UIKit
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

enum MXTheme {
    static let bg          = Color(hex: "0d0d0d")
    static let surface     = Color(hex: "1a1a1a")
    static let surfaceAlt  = Color(hex: "222222")
    static let border      = Color(hex: "2a2a2a")
    static let borderLight = Color(hex: "333333")
    static let text        = Color(hex: "f0f0ef")
    static let muted       = Color(hex: "888888")
    static let dim         = Color(hex: "555555")
    static let accent      = Color(hex: "e8c84a")
    static let partBlue    = Color(hex: "7ab8e8")
    static let laborGreen  = Color(hex: "6dcf6d")
    static let header      = Color(hex: "111111")
}
