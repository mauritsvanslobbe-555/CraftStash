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
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Header
                            HStack {
                                Text(L.tabFavorites)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.rose)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                            Text("\(favorites.count) items")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.inkMute)
                                .padding(.horizontal, 20)
                                .padding(.top, 4)

                            MasonryGrid(items: favorites) { item in
                                selectedItem = item
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedItem) { item in
                CraftItemDetailView(item: item)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.rose)

            Text(L.noFavorites)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.ink)

            Text(L.markFavorites)
                .font(.system(size: 13.5))
                .foregroundStyle(Theme.inkMute)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding()
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
