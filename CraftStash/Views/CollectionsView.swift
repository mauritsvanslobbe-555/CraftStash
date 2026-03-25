import SwiftUI
import SwiftData

struct CollectionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftCollection.dateCreated, order: .reverse) private var collections: [CraftCollection]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if collections.isEmpty {
                    emptyStateView
                } else {
                    collectionsListView
                }
            }
            .navigationTitle("Collecties")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCollectionSheet()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "folder.fill.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(Theme.color(for: "ocean"))

            Text("Maak je eerste collectie!")
                .font(.title2.bold())

            Text("Organiseer je knutselideeën in\ngroepen zoals 'Kerst', 'Verjaardag'\nof 'Makkelijk'")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddSheet = true
            } label: {
                Label("Nieuwe collectie", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.color(for: "ocean"))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    private var collectionsListView: some View {
        ScrollView {
            LazyVGrid(columns: Theme.gridColumns, spacing: 16) {
                ForEach(collections) { collection in
                    NavigationLink(destination: CollectionDetailView(collection: collection)) {
                        CollectionCard(collection: collection)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            modelContext.delete(collection)
                        } label: {
                            Label("Verwijderen", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct CollectionCard: View {
    let collection: CraftCollection

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(Theme.color(for: collection.colorName).gradient)
                    .frame(height: 120)

                Image(systemName: collection.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 4) {
                Text(collection.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("\(collection.itemCount) ideeën")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: Theme.cardShadowRadius, y: 2)
        )
    }
}

#Preview {
    CollectionsView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
}
