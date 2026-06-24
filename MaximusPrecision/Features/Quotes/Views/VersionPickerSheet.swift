//
//  VersionPickerSheet.swift
//  MaximusPrecision
//
//  Quick optional picker for a model's trim/version (e.g. "Advance", "High
//  Country"). Reached from the model pill; choosing a version is optional —
//  "Sin versión específica" leaves just the model.
//

import SwiftUI

struct VersionPickerSheet: View {
    let modelName: String
    let trims: [String]
    /// Passes back the chosen trim, or `nil` for "no specific version".
    let onPick: (String?) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    row(label: "Sin versión específica", muted: true) {
                        onPick(nil)
                        dismiss()
                    }
                    .accessibilityIdentifier(A11y.VersionPicker.none)

                    ForEach(Array(trims.enumerated()), id: \.element) { index, trim in
                        row(label: trim, muted: false) {
                            onPick(trim)
                            dismiss()
                        }
                        .accessibilityIdentifier(A11y.VersionPicker.trim(index))
                    }
                }
                .padding(16)
            }
            .background(MXTheme.bg.ignoresSafeArea())
            .navigationTitle("Versión · \(modelName)")
            .navigationBarTitleDisplayMode(.inline)
            .navBarDarkChrome(MXTheme.header)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(MXTheme.muted)
                        .accessibilityIdentifier(A11y.VersionPicker.close)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }

    private func row(label: String, muted: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 16, weight: muted ? .regular : .medium))
                    .foregroundStyle(muted ? MXTheme.muted : MXTheme.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(MXTheme.dim)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MXTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(MXTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
