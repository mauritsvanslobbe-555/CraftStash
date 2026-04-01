import SwiftUI
import SwiftData

struct AddCollectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = "coral"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview card
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Theme.color(for: selectedColor).gradient)
                                .frame(height: 100)

                            Image(systemName: selectedIcon)
                                .font(.system(size: 36))
                                .foregroundStyle(.white)
                        }

                        Text(name.isEmpty ? "Naam collectie" : name)
                            .font(.headline)
                            .foregroundStyle(name.isEmpty ? .tertiary : .primary)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Naam")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        TextField("Bijv. Kerstknutsels", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                    .padding(.horizontal)

                    // Icon picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kies een icoon")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(CraftCollection.availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title3)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedIcon == icon
                                                      ? Theme.color(for: selectedColor).opacity(0.2)
                                                      : Color(.tertiarySystemFill))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedIcon == icon ? Theme.color(for: selectedColor) : .clear, lineWidth: 2)
                                        )
                                        .foregroundStyle(selectedIcon == icon
                                                         ? Theme.color(for: selectedColor)
                                                         : .secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Color picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kies een kleur")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(CraftCollection.availableColors, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(Theme.color(for: color))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.headline.bold())
                                                .foregroundStyle(.white)
                                                .opacity(selectedColor == color ? 1 : 0)
                                        )
                                        .shadow(color: selectedColor == color ? Theme.color(for: color).opacity(0.5) : .clear, radius: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Nieuwe collectie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Maak aan") {
                        createCollection()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .bold()
                }
            }
        }
    }

    private func createCollection() {
        let collection = CraftCollection(
            name: name.trimmingCharacters(in: .whitespaces),
            icon: selectedIcon,
            colorName: selectedColor
        )
        modelContext.insert(collection)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddCollectionSheet()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
}
