//
//  YearPickerSheet.swift
//  MaximusPrecision
//
//  Quick year picker: a grid of years (newest first) with the current pick
//  highlighted. The range is clamped to the selected model's first year when
//  one is known, so only valid years are offered.
//

import SwiftUI

struct YearPickerSheet: View {
    let minYear: Int
    let maxYear: Int
    let selected: Int?
    let onPick: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    private var years: [Int] { Array(stride(from: maxYear, through: minYear, by: -1)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(years.enumerated()), id: \.element) { index, year in
                        yearButton(year, index: index)
                    }
                }
                .padding(16)
            }
            .background(MXTheme.bg.ignoresSafeArea())
            .navigationTitle("Año")
            .navigationBarTitleDisplayMode(.inline)
            .navBarDarkChrome(MXTheme.header)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(MXTheme.muted)
                        .accessibilityIdentifier(A11y.YearPicker.close)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }

    private func yearButton(_ year: Int, index: Int) -> some View {
        let isSelected = year == selected
        return Button {
            onPick(year)
            dismiss()
        } label: {
            Text(String(year))
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? Color(hex: "111111") : MXTheme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(isSelected ? MXTheme.accent : MXTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : MXTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11y.YearPicker.year(index))
    }
}
