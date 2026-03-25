import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    @Bindable var collection: CraftCollection
    @Environment(\.modelContext) private var modelContext
    @State private var selectedItem: CraftItem?
    @State private var showingAddItems = false

    var body: some View {
        Group {
            if let items = collection.items, !items.isEmpty {
                ScrollView {
                    LazyVGrid(columns: Theme.gridColumns, spacing: 12) {
                        ForEach(items.sorted(by: { $0.dateAdded > $1.dateAdded })) { item in
                            CraftItemCard(item: item, style: .grid)
                                .onTapGesture { selectedItem = item }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        collection.items?.removeAll(where: { $0.id == item.id })
                                    } label: {
                                        Label("Verwijder uit collectie", systemImage: "folder.badge.minus")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: collection.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.color(for: collection.colorName))

                    Text("Collectie is leeg")
                        .font(.title3.bold())

                    Text("Voeg knutselideeën toe vanuit\nhet startscherm")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        showingAddItems = true
                    } label: {
                        Label("Ideeën toevoegen", systemImage: "plus")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Theme.color(for: collection.colorName))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding()
            }
        }
        .navigationTitle(collection.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddItems = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            CraftItemDetailView(item: item)
        }
        .sheet(isPresented: $showingAddItems) {
            AddItemsToCollectionSheet(collection: collection)
        }
    }
}
