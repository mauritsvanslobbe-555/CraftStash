import SwiftUI
import SwiftData
import PhotosUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftItem.dateAdded, order: .reverse) private var items: [CraftItem]
    @State private var searchText = ""
    @State private var selectedItem: CraftItem?
    @State private var showingImportSheet = false
    @State private var showingImagePicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

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
            .navigationTitle("CraftStash")
            .safeAreaInset(edge: .top) {
                if items.isEmpty {
                    EmptyView()
                } else if !hasSeenWelcome {
                    welcomeBanner
                }
            }
            .searchable(text: $searchText, prompt: "Zoek knutselideeën...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingImportSheet = true
                        } label: {
                            Label("Link toevoegen", systemImage: "link.badge.plus")
                        }
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("Screenshot opslaan", systemImage: "photo.on.rectangle.angled")
                        }
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
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhotos, maxSelectionCount: 10, matching: .images)
            .onChange(of: selectedPhotos) { _, newItems in
                importPhotos(newItems)
            }
            .onAppear {
                importPendingSharedItems()
            }
        }
    }

    private var welcomeBanner: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tip: Zo bewaar je ideeën")
                        .font(.subheadline.bold())
                    Text("Zie je een leuk knutselfilmpje? Tik op de deel-knop en kies CraftStash!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    withAnimation { hasSeenWelcome = true }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
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

    private func importPhotos(_ photos: [PhotosPickerItem]) {
        Task {
            for photo in photos {
                if let data = try? await photo.loadTransferable(type: Data.self) {
                    let fileName = "\(UUID().uuidString).jpg"
                    let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let imageDir = docsURL.appendingPathComponent("SavedImages", isDirectory: true)
                    try? FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
                    let fileURL = imageDir.appendingPathComponent(fileName)
                    try? data.write(to: fileURL)

                    let item = CraftItem(
                        title: "Screenshot knutselidee",
                        urlString: fileURL.absoluteString,
                        thumbnailURLString: fileURL.absoluteString,
                        sourcePlatform: "Screenshot"
                    )
                    await MainActor.run {
                        modelContext.insert(item)
                    }
                }
            }
            await MainActor.run {
                selectedPhotos = []
                try? modelContext.save()
            }
        }
    }

    private func importPendingSharedItems() {
        let pending = SharedDataManager.loadPendingItems()
        guard !pending.isEmpty else { return }

        for shared in pending {
            let thumbnailURL = Self.generateThumbnailURL(for: shared.urlString)
            let item = CraftItem(
                title: shared.title ?? "Knutselidee",
                urlString: shared.urlString,
                thumbnailURLString: thumbnailURL,
                sourcePlatform: shared.sourcePlatform
            )
            modelContext.insert(item)
        }

        SharedDataManager.clearPendingItems()
        try? modelContext.save()
    }

    static func generateThumbnailURL(for urlString: String) -> String? {
        let lowered = urlString.lowercased()

        // YouTube thumbnail
        if lowered.contains("youtube.com/watch") {
            if let url = URL(string: urlString),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let videoID = components.queryItems?.first(where: { $0.name == "v" })?.value {
                return "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
            }
        }
        if lowered.contains("youtu.be/") {
            if let url = URL(string: urlString) {
                let videoID = url.lastPathComponent
                return "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
            }
        }
        if lowered.contains("youtube.com/shorts/") {
            if let url = URL(string: urlString) {
                let parts = url.pathComponents
                if let idx = parts.firstIndex(of: "shorts"), idx + 1 < parts.count {
                    return "https://img.youtube.com/vi/\(parts[idx + 1])/hqdefault.jpg"
                }
            }
        }

        return nil
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
