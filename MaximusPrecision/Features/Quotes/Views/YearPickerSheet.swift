//
//  YearPickerSheet.swift
//  MaximusPrecision
//
//  Quick year picker: a grid of years (newest first) with the current pick
//  highlighted. The range is clamped to the selected model's first year when
//  one is known. For vehicles older than the range (more than 10 years), the
//  "Más de 10 años" flag switches to manual year entry.
//

import SwiftUI

struct YearPickerSheet: View {
    let minYear: Int
    let maxYear: Int
    let selected: Int?
    @Binding var manualMode: Bool
    let onPick: (Int) -> Void
    let onManual: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var manualText: String = ""

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    private var years: [Int] { Array(stride(from: maxYear, through: minYear, by: -1)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    manualToggle

                    if manualMode {
                        manualEntry
                    } else {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(Array(years.enumerated()), id: \.element) { index, year in
                                yearButton(year, index: index)
                            }
                        }
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

    // MARK: Manual-entry flag

    private var manualToggle: some View {
        Button {
            manualMode.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: manualMode ? "checkmark.square.fill" : "square")
                    .foregroundStyle(manualMode ? MXTheme.accent : MXTheme.muted)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Auto de más de 10 años")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MXTheme.text)
                    Text("Escribe el año manualmente")
                        .font(.system(size: 11))
                        .foregroundStyle(MXTheme.muted)
                }
                Spacer()
            }
            .padding(12)
            .background(MXTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(manualMode ? MXTheme.accent.opacity(0.5) : MXTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11y.YearPicker.manualToggle)
    }

    private var manualEntry: some View {
        VStack(spacing: 12) {
            TextField("Ej. 2008", text: $manualText)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .foregroundStyle(MXTheme.text)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(MXTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MXTheme.border, lineWidth: 1)
                )
                .accessibilityIdentifier(A11y.YearPicker.manualField)

            Button {
                onManual(manualText)
                dismiss()
            } label: {
                Text("Usar año")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(hex: "111111"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isValid ? MXTheme.accent : MXTheme.accent.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!isValid)
            .accessibilityIdentifier(A11y.YearPicker.manualConfirm)
        }
        .onAppear { if manualText.isEmpty, let s = selected { manualText = String(s) } }
    }

    private var isValid: Bool {
        let digits = manualText.filter(\.isNumber)
        guard digits.count == 4, let year = Int(digits) else { return false }
        return year >= 1900 && year <= maxYear
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
