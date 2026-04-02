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
            ZStack {
                Theme.bg.ignoresSafeArea()

                if favorites.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        MasonryGrid(items: favorites) { item in
                            selectedItem = item
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Favorieten")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedItem) { item in
                CraftItemDetailView(item: item)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.danger)

            Text("Geen favorieten")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Markeer knutselideeën als favoriet\nom ze hier terug te vinden!")
                .font(.callout)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
