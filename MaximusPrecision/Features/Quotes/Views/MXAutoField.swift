import SwiftUI

struct MXAutoField: View {
    let label: String
    @Binding var text: String
    let suggestions: [String]
    let onSelect: (String) -> Void
    
    @State private var isDropdownVisible = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(MXTheme.muted)
                .kerning(0.8)
            
            ZStack(alignment: .topLeading) {
                TextField("", text: $text)
                    .font(.system(size: 15))
                    .foregroundStyle(MXTheme.text)
                    .tint(MXTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    .background(MXTheme.surfaceAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(MXTheme.borderLight, lineWidth: 1.5)
                    )
                    .focused($isFocused)
                    .onChange(of: isFocused) { _, focused in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isDropdownVisible = focused && !suggestions.isEmpty
                        }
                    }
                    .onChange(of: text) { _, _ in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isDropdownVisible = isFocused && !suggestions.isEmpty
                        }
                    }
                
                if isDropdownVisible && !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: {
                                onSelect(suggestion)
                                isDropdownVisible = false
                                isFocused = false
                            }) {
                                HStack {
                                    highlightedText(suggestion, query: text)
                                        .font(.system(size: 14))
                                        .foregroundStyle(MXTheme.text)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if suggestion != suggestions.last {
                                Rectangle()
                                    .fill(MXTheme.border)
                                    .frame(height: 1)
                            }
                        }
                    }
                    .background(MXTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(MXTheme.border, lineWidth: 1)
                    )
                    .offset(y: 48)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .zIndex(10)
        }
    }
    
    private func highlightedText(_ fullText: String, query: String) -> some View {
        guard let range = fullText.lowercased().range(of: query.lowercased()) else {
            return Text(fullText)
        }
        
        let prefix = String(fullText[..<range.lowerBound])
        let match = String(fullText[range])
        let suffix = String(fullText[range.upperBound...])
        
        return Text(prefix) + Text(match).foregroundColor(MXTheme.accent).bold() + Text(suffix)
    }
}
