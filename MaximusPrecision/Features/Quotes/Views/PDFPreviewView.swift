import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let url: URL
    @State private var showShareSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            MXTheme.bg.ignoresSafeArea()

            PDFKitView(url: url)
                .padding(.bottom, 88)

            shareBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MXTheme.header, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Vista previa PDF")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(MXTheme.text)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [url])
        }
        .preferredColorScheme(.dark)
    }

    private var shareBar: some View {
        HStack(spacing: 10) {
            Button {
                shareViaWhatsApp()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 15))
                    Text("WhatsApp")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "25D366"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15))
                    Text("Correo / Más")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(MXTheme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(MXTheme.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MXTheme.borderLight, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .background(MXTheme.header)
        .overlay(alignment: .top) {
            Rectangle().fill(MXTheme.border).frame(height: 1)
        }
    }

    private func shareViaWhatsApp() {
        let urlString = "whatsapp://send?text=Cotización%20adjunta"
        if let whatsappURL = URL(string: urlString),
           UIApplication.shared.canOpenURL(whatsappURL) {
            showShareSheet = true
        } else {
            showShareSheet = true
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = UIColor(MXTheme.bg)
        view.document = PDFDocument(url: url)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}
