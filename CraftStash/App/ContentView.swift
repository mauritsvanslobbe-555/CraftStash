import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .home

    enum Tab: String {
        case home, collections, favorites
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Ontdek", systemImage: "sparkles")
                }
                .tag(Tab.home)

            CollectionsView()
                .tabItem {
                    Label("Collecties", systemImage: "folder.fill")
                }
                .tag(Tab.collections)

            FavoritesView()
                .tabItem {
                    Label("Favorieten", systemImage: "heart.fill")
                }
                .tag(Tab.favorites)
        }
        .tint(Theme.primaryColor)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
}
