import SwiftUI

struct AddCollectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = "coral"

    var body: some View {
        NavigationStack {
            Form {
                Section("Naam") {
                    TextField("Bijv. Kerstknutsels", text: $name)
                }

                Section("Icoon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(CraftCollection.availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon
                                                  ? Theme.color(for: selectedColor).opacity(0.2)
                                                  : Color(.tertiarySystemFill))
                                    )
                                    .foregroundStyle(selectedIcon == icon
                                                     ? Theme.color(for: selectedColor)
                                                     : .secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Kleur") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(CraftCollection.availableColors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(Theme.color(for: color))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Theme.color(for: color), lineWidth: selectedColor == color ? 1 : 0)
                                            .padding(2)
                                    )
                                    .shadow(color: selectedColor == color ? Theme.color(for: color).opacity(0.4) : .clear, radius: 4)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    // Preview
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Theme.color(for: selectedColor))
                                .frame(width: 48, height: 48)
                            Image(systemName: selectedIcon)
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading) {
                            Text(name.isEmpty ? "Naam collectie" : name)
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? .tertiary : .primary)
                            Text("0 ideeën")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Voorbeeld")
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
                        let collection = CraftCollection(
                            name: name,
                            icon: selectedIcon,
                            colorName: selectedColor
                        )
                        modelContext.insert(collection)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddCollectionSheet()
        .modelContainer(for: CraftCollection.self, inMemory: true)
}
