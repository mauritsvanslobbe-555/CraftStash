import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    enum Tab: String {
        case home, collections, search, favorites, guide
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            CollectionsView()
                .tabItem {
                    Label("Collecties", systemImage: "square.grid.2x2.fill")
                }
                .tag(Tab.collections)

            SearchView()
                .tabItem {
                    Label("Zoeken", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)

            FavoritesView()
                .tabItem {
                    Label("Favorieten", systemImage: "heart.fill")
                }
                .tag(Tab.favorites)

            GuideView()
                .tabItem {
                    Label("Help", systemImage: "questionmark.circle")
                }
                .tag(Tab.guide)
        }
        .tint(Theme.primaryColor)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
}
