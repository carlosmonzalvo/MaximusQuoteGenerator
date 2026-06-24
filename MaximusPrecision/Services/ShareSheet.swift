//
//  ShareSheet.swift
//  MaximusPrecision
//
//  Cross-platform share affordance. iOS uses UIActivityViewController; macOS
//  offers native actions (open in Preview, reveal in Finder, system share).
//

import SwiftUI

#if os(iOS)
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#else
import AppKit

struct ShareSheet: View {
    let items: [Any]
    @Environment(\.dismiss) private var dismiss

    private var url: URL? { items.compactMap { $0 as? URL }.first }

    var body: some View {
        VStack(spacing: 16) {
            Text("Compartir documento")
                .font(.headline)

            if let url {
                Button {
                    NSWorkspace.shared.open(url)
                    dismiss()
                } label: {
                    Label("Abrir en Vista Previa", systemImage: "doc.richtext")
                        .frame(maxWidth: .infinity)
                }

                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                    dismiss()
                } label: {
                    Label("Mostrar en Finder", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                }

                SharingPicker(url: url)
                    .frame(maxWidth: .infinity)
            } else {
                Text("No hay documento para compartir.")
                    .foregroundStyle(.secondary)
            }

            Button("Cerrar") { dismiss() }
                .keyboardShortcut(.cancelAction)
        }
        .padding(24)
        .frame(width: 320)
    }
}

/// Wraps the native macOS share menu (mail, AirDrop, Messages, …).
private struct SharingPicker: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(title: "Compartir…", target: context.coordinator, action: #selector(Coordinator.share(_:)))
        button.bezelStyle = .rounded
        return button
    }

    func updateNSView(_ nsView: NSButton, context: Context) {
        context.coordinator.url = url
    }

    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    final class Coordinator: NSObject {
        var url: URL
        init(url: URL) { self.url = url }

        @objc func share(_ sender: NSButton) {
            let picker = NSSharingServicePicker(items: [url])
            picker.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        }
    }
}
#endif
