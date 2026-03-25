import SwiftUI
import SwiftData

struct AddItemsToCollectionSheet: View {
    let collection: CraftCollection
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CraftItem.dateAdded, order: .reverse) private var allItems: [CraftItem]

    var body: some View {
        NavigationStack {
            List {
                if allItems.isEmpty {
                    ContentUnavailableView {
                        Label("Geen ideeën", systemImage: "scissors")
                    } description: {
                        Text("Deel eerst knutselideeën naar CraftStash")
                    }
                }

                ForEach(allItems) { item in
                    Button {
                        toggleItem(item)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(item.sourcePlatform)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if isInCollection(item) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.color(for: collection.colorName))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ideeën toevoegen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Klaar") { dismiss() }
                }
            }
        }
    }

    private func isInCollection(_ item: CraftItem) -> Bool {
        collection.items?.contains(where: { $0.id == item.id }) ?? false
    }

    private func toggleItem(_ item: CraftItem) {
        if isInCollection(item) {
            collection.items?.removeAll(where: { $0.id == item.id })
        } else {
            if collection.items == nil {
                collection.items = []
            }
            collection.items?.append(item)
        }
    }
}
