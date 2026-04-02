import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    @Bindable var collection: CraftCollection
    @Environment(\.modelContext) private var modelContext
    @State private var selectedItem: CraftItem?
    @State private var showingAddItems = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            if let items = collection.items, !items.isEmpty {
                ScrollView {
                    MasonryGrid(items: items.sorted(by: { $0.dateAdded > $1.dateAdded })) { item in
                        selectedItem = item
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: collection.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.color(for: collection.colorName))

                    Text("Collectie is leeg")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Text("Voeg knutselideeën toe")
                        .font(.callout)
                        .foregroundStyle(Theme.textSecondary)

                    Button {
                        showingAddItems = true
                    } label: {
                        Label("Ideeën toevoegen", systemImage: "plus")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Theme.accentGradient)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding()
            }
        }
        .navigationTitle(collection.name)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddItems = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Theme.primaryColor)
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
