import Foundation

/// The kind of document being produced. Controls the on-screen and PDF title
/// as well as the generated file name.
enum DocumentType: String, CaseIterable, Codable, Hashable {
    case quote = "Cotización"
    case remision = "Nota de remisión"

    /// Human title shown in the header and printed on the PDF.
    var title: String { rawValue }

    /// Short label used in the segmented switch.
    var shortLabel: String {
        switch self {
        case .quote: return "Cotización"
        case .remision: return "Remisión"
        }
    }

    /// Prefix for the exported PDF file name.
    var fileNamePrefix: String {
        switch self {
        case .quote: return "Cotizacion"
        case .remision: return "Remision"
        }
    }
}
