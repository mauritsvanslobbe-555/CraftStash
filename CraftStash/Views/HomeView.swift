import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftItem.dateAdded, order: .reverse) private var items: [CraftItem]
    @State private var searchText = ""
    @State private var selectedItem: CraftItem?
    @State private var showingImportSheet = false

    var filteredItems: [CraftItem] {
        if searchText.isEmpty {
            return items
        }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.sourcePlatform.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyStateView
                } else {
                    itemsGridView
                }
            }
            .navigationTitle("CraftStash ✂️")
            .searchable(text: $searchText, prompt: "Zoek knutselideeën...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingImportSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                CraftItemDetailView(item: item)
            }
            .sheet(isPresented: $showingImportSheet) {
                AddItemManuallySheet()
            }
            .onAppear {
                importPendingSharedItems()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "scissors")
                .font(.system(size: 64))
                .foregroundStyle(Theme.color(for: "coral"))

            Text("Nog geen knutselideeën!")
                .font(.title2.bold())

            Text("Deel een filmpje of plaatje vanuit\nYouTube, Pinterest, Instagram of\neen andere app naar CraftStash!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                PlatformBadge(name: "YouTube", icon: "play.rectangle.fill", color: .red)
                PlatformBadge(name: "Pinterest", icon: "pin.fill", color: Theme.color(for: "berry"))
                PlatformBadge(name: "Instagram", icon: "camera.fill", color: .purple)
                PlatformBadge(name: "TikTok", icon: "music.note", color: .primary)
            }
        }
        .padding()
    }

    private var itemsGridView: some View {
        ScrollView {
            if !recentItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent toegevoegd")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(recentItems) { item in
                                CraftItemCard(item: item, style: .horizontal)
                                    .onTapGesture { selectedItem = item }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 180)
                }
                .padding(.top)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Alle ideeën")
                    .font(.headline)
                    .padding(.horizontal)

                LazyVGrid(columns: Theme.gridColumns, spacing: 12) {
                    ForEach(filteredItems) { item in
                        CraftItemCard(item: item, style: .grid)
                            .onTapGesture { selectedItem = item }
                            .contextMenu {
                                Button {
                                    item.isFavorite.toggle()
                                } label: {
                                    Label(
                                        item.isFavorite ? "Verwijder favoriet" : "Favoriet",
                                        systemImage: item.isFavorite ? "heart.slash" : "heart"
                                    )
                                }

                                Button(role: .destructive) {
                                    modelContext.delete(item)
                                } label: {
                                    Label("Verwijderen", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }

    private var recentItems: [CraftItem] {
        Array(items.prefix(6))
    }

    private func importPendingSharedItems() {
        let pending = SharedDataManager.loadPendingItems()
        guard !pending.isEmpty else { return }

        for shared in pending {
            let item = CraftItem(
                title: shared.title ?? "Knutselidee",
                urlString: shared.urlString,
                sourcePlatform: shared.sourcePlatform
            )
            modelContext.insert(item)
        }

        SharedDataManager.clearPendingItems()
        try? modelContext.save()
    }
}

struct PlatformBadge: View {
    let name: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
}
