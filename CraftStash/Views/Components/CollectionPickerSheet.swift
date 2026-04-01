import SwiftUI
import SwiftData

struct CollectionPickerSheet: View {
    let item: CraftItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftCollection.name) private var collections: [CraftCollection]
    @State private var showingNewCollection = false

    var body: some View {
        NavigationStack {
            List {
                if collections.isEmpty {
                    ContentUnavailableView {
                        Label("Geen collecties", systemImage: "folder")
                    } description: {
                        Text("Maak eerst een collectie aan")
                    }
                }

                ForEach(collections) { collection in
                    Button {
                        toggleCollection(collection)
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Theme.color(for: collection.colorName))
                                    .frame(width: 36, height: 36)
                                Image(systemName: collection.icon)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }

                            Text(collection.name)
                                .foregroundStyle(.primary)

                            Spacer()

                            if isInCollection(collection) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.color(for: collection.colorName))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Toevoegen aan collectie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Klaar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewCollection = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewCollection) {
                AddCollectionSheet()
            }
        }
    }

    private func isInCollection(_ collection: CraftCollection) -> Bool {
        collection.items?.contains(where: { $0.id == item.id }) ?? false
    }

    private func toggleCollection(_ collection: CraftCollection) {
        if isInCollection(collection) {
            collection.items?.removeAll(where: { $0.id == item.id })
        } else {
            if collection.items == nil {
                collection.items = []
            }
            collection.items?.append(item)
        }
        try? modelContext.save()
    }
}
