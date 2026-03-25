import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(filter: #Predicate<CraftItem> { $0.isFavorite },
           sort: \CraftItem.dateAdded,
           order: .reverse)
    private var favorites: [CraftItem]

    @State private var selectedItem: CraftItem?

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    emptyStateView
                } else {
                    favoritesGridView
                }
            }
            .navigationTitle("Favorieten")
            .sheet(item: $selectedItem) { item in
                CraftItemDetailView(item: item)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.color(for: "berry"))

            Text("Geen favorieten")
                .font(.title2.bold())

            Text("Markeer knutselideeën als favoriet\nom ze hier terug te vinden!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var favoritesGridView: some View {
        ScrollView {
            LazyVGrid(columns: Theme.gridColumns, spacing: 12) {
                ForEach(favorites) { item in
                    CraftItemCard(item: item, style: .grid)
                        .onTapGesture { selectedItem = item }
                }
            }
            .padding()
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
}
