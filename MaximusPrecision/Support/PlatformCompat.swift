//
//  PlatformCompat.swift
//  MaximusPrecision
//
//  Minimal shims so the shared SwiftUI views compile natively on macOS without
//  sprinkling `#if os(iOS)` at every call site. On macOS the iOS-only view
//  modifiers below become no-ops; on iOS this file contributes nothing.
//

import SwiftUI

extension View {
    /// Dark navigation-bar chrome — applied on iOS, a no-op on macOS where the
    /// concept doesn't exist.
    @ViewBuilder
    func navBarDarkChrome(_ color: Color) -> some View {
        #if os(iOS)
        self
            .toolbarBackground(color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        #else
        self
        #endif
    }

    /// Hides the navigation bar on iOS; no-op on macOS (no nav bar there).
    @ViewBuilder
    func hiddenNavBar() -> some View {
        #if os(iOS)
        self.toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }
}

#if os(macOS)

/// Stand-ins for the iOS-only enums these modifiers expect, so call sites like
/// `.keyboardType(.numberPad)` still type-check on macOS.
enum UIKeyboardType {
    case `default`, asciiCapable, numbersAndPunctuation, numberPad
    case phonePad, namePhonePad, emailAddress, decimalPad, twitter, webSearch
}

enum UITextAutocapitalizationType {
    case none, words, sentences, allCharacters
}

enum NavigationBarItemTitleDisplayMode {
    case automatic, inline, large
}

/// Mirror of SwiftUI's iOS-only `TextInputAutocapitalization` so views can store
/// and pass it around on macOS.
struct TextInputAutocapitalization {
    static let never = TextInputAutocapitalization()
    static let words = TextInputAutocapitalization()
    static let sentences = TextInputAutocapitalization()
    static let characters = TextInputAutocapitalization()
}

extension View {
    func keyboardType(_ type: UIKeyboardType) -> some View { self }
    func autocapitalization(_ style: UITextAutocapitalizationType) -> some View { self }
    func textInputAutocapitalization(_ style: TextInputAutocapitalization?) -> some View { self }
    func navigationBarTitleDisplayMode(_ mode: NavigationBarItemTitleDisplayMode) -> some View { self }
}

#endif
