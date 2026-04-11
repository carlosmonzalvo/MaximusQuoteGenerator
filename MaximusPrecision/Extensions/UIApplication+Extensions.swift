//
//  UIApplication+Extensions.swift
//  MaximusPrecision
//
//  Created by Pedro Carlos  Monzalvo Navarro on 03/04/26.
//

import UIKit
import SwiftUICore

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
