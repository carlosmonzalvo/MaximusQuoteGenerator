//
//  RootTabView.swift
//  MaximusPrecision
//
//  App shell: the quote/document builder and the client/vehicle expedientes.
//  On iOS 26 the expedientes search lives in the Liquid Glass tab bar via a
//  dedicated search-role tab; earlier OSes use an inline search field.
//

import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var recordsVM = RecordsViewModel()

    var body: some View {
        content
            .onAppear { recordsVM.load(context: modelContext) }
    }

    @ViewBuilder
    private var content: some View {
        if #available(iOS 26.0, *) {
            TabView {
                Tab("Cotizar", systemImage: "doc.text") {
                    QuoteFormView()
                }

                Tab("Expedientes", systemImage: "car.2") {
                    RecordsView(vm: recordsVM)
                }

                Tab(role: .search) {
                    RecordsSearchView(vm: recordsVM)
                }
            }
        } else {
            TabView {
                QuoteFormView()
                    .tabItem { Label("Cotizar", systemImage: "doc.text") }
                    .accessibilityIdentifier(A11y.RootTab.quote)

                RecordsView(vm: recordsVM)
                    .tabItem { Label("Expedientes", systemImage: "car.2") }
                    .accessibilityIdentifier(A11y.RootTab.records)
            }
        }
    }
}
