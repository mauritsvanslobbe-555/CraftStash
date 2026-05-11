import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var selectedTab: Tab = .home

    enum Tab: String {
        case home, collections, search, favorites, guide
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(L.tabHome, systemImage: "house.fill")
                }
                .tag(Tab.home)

            CollectionsView()
                .tabItem {
                    Label(L.tabCollections, systemImage: "square.grid.2x2.fill")
                }
                .tag(Tab.collections)

            SearchView()
                .tabItem {
                    Label(L.tabSearch, systemImage: "magnifyingglass")
                }
                .tag(Tab.search)

            FavoritesView()
                .tabItem {
                    Label(L.tabFavorites, systemImage: "heart.fill")
                }
                .tag(Tab.favorites)

            GuideView()
                .tabItem {
                    Label(L.tabHelp, systemImage: "questionmark.circle")
                }
                .tag(Tab.guide)
        }
        .tint(Theme.primaryColor)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
}
