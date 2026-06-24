//
//  RootTabView.swift
//  MaximusPrecision
//
//  App shell: the quote/document builder and the client/vehicle expedientes.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            QuoteFormView()
                .tabItem {
                    Label("Cotizar", systemImage: "doc.text")
                }
                .accessibilityIdentifier(A11y.RootTab.quote)

            RecordsView()
                .tabItem {
                    Label("Expedientes", systemImage: "car.2")
                }
                .accessibilityIdentifier(A11y.RootTab.records)
        }
    }
}
