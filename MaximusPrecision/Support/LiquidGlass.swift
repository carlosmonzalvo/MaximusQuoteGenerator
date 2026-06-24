//
//  LiquidGlass.swift
//  MaximusPrecision
//
//  Liquid Glass (iOS 26) surfaces with a graceful fallback to the existing
//  material styling on earlier OS versions, so the app keeps building for the
//  iOS 17 deployment target.
//

import SwiftUI

extension View {
    /// Glassy capsule/pill. Tinted + interactive when selected.
    @ViewBuilder
    func glassPill(selected: Bool, tint: Color) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                selected ? .regular.tint(tint).interactive() : .regular.interactive(),
                in: .rect(cornerRadius: 10)
            )
        } else {
            self
                .background(selected ? tint : MXTheme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selected ? Color.clear : MXTheme.borderLight, lineWidth: 1.5)
                )
        }
    }

    /// Glassy rounded card surface.
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 12, fallbackFill: Color = MXTheme.surface) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(fallbackFill)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(MXTheme.borderLight, lineWidth: 1)
                )
        }
    }

    /// Prominent glass action button surface (tinted, interactive).
    @ViewBuilder
    func glassAction(tint: Color, cornerRadius: CGFloat = 14) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(tint)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
