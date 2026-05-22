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
    @State private var activeFilter = "Alles"
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    private let filters = ["Alles", "Video's", "Foto's", "YouTube", "Instagram", "TikTok", "Pinterest"]

    var filteredItems: [CraftItem] {
        var result = items

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.sourcePlatform.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch activeFilter {
        case "Video's":
            result = result.filter { $0.isVideo }
        case "Foto's":
            result = result.filter { !$0.isVideo }
        case "Alles":
            break
        default:
            result = result.filter { $0.sourcePlatform.localizedCaseInsensitiveContains(activeFilter) }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if items.isEmpty {
                    emptyStateView
                } else {
                    mainContentView
                }
            }
            .navigationBarHidden(true)
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

    // MARK: - Header
    private var headerView: some View {
        HStack {
            // Left: avatar + greeting
            HStack(spacing: 10) {
                // Gradient avatar circle
                Circle()
                    .fill(Theme.accentGradient)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text("S")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text("JOUW STASH")
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.inkDim)
                        .tracking(1)
                    Text("Hoi")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
            }

            Spacer()

            // Right: language flag + stash button
            HStack(spacing: 8) {
                // + Stash button
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
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Stash")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .background(Theme.primary)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Search Bar
    private var searchBarView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(Theme.inkMute)

            TextField("", text: $searchText, prompt: Text("Zoek in je stash...").foregroundStyle(Theme.inkMute))
                .font(.system(size: 14.5))
                .foregroundStyle(Theme.ink)
                .tint(Theme.primary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.inkDim)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Theme.border, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerView

                searchBarView
                    .padding(.top, 14)

                // Tip card
                if !hasSeenWelcome {
                    tipCard
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                }

                // Stats row
                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(items.count)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Theme.ink)
                        Text("items")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.inkMute)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.inkDim)
                        Text("NIEUWSTE")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(Theme.inkDim)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            SSFilterChip(
                                label: filter,
                                isActive: activeFilter == filter,
                                platformColor: platformDotColor(for: filter)
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    activeFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
                .padding(.bottom, 12)

                // Masonry Grid
                MasonryGrid(items: filteredItems) { item in
                    selectedItem = item
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Tip Card
    private var tipCard: some View {
        HStack(spacing: 12) {
            // Bolt icon
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.25))
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Tip: Deel vanuit elke app")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text("Tik op Delen en kies CraftStash")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                withAnimation { hasSeenWelcome = true }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(14)
        .background(Theme.warmGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                searchBarView
                    .padding(.top, 14)

                Spacer(minLength: 60)

                VStack(spacing: 8) {
                    // Dashed box with inbox icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.primaryTint, .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .strokeBorder(Theme.borderHi, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            )

                        Image(systemName: "tray.and.arrow.down")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.primarySoft)
                    }
                    .padding(.bottom, 16)

                    Text("Jouw stash is leeg")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.ink)

                    Text("Bewaar je eerste idee vanuit Instagram, TikTok of een andere app -- tik op delen \u{2192} StuffStash.")
                        .font(.system(size: 13.5))
                        .foregroundStyle(Theme.inkMute)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260)
                        .lineSpacing(2)

                    Button {
                        showingImportSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))
                            Text("Toon mij hoe")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 46)
                        .background(Theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Theme.primary.opacity(0.4), radius: 12, y: 4)
                    }
                    .padding(.top, 18)
                }

                Spacer(minLength: 60)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Helpers
    private func platformDotColor(for filter: String) -> Color? {
        switch filter {
        case "YouTube":    return Theme.ytRed
        case "Instagram":  return Theme.igPink
        case "TikTok":     return Theme.ttCyan
        case "Pinterest":  return Theme.pinRed
        default: return nil
        }
    }

    // MARK: - Import Functions
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
                        title: "Screenshot",
                        urlString: fileURL.absoluteString,
                        thumbnailURLString: "SavedImages/\(fileName)",
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

        var itemsNeedingThumbnails: [(CraftItem, String)] = []

        for shared in pending {
            var thumbnailURL: String? = Self.generateThumbnailURL(for: shared.urlString)

            if let imageFileName = shared.imageFileName,
               let sharedImageURL = SharedDataManager.sharedImageURL(for: imageFileName) {
                let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let imageDir = docsURL.appendingPathComponent("SavedImages", isDirectory: true)
                try? FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
                let localURL = imageDir.appendingPathComponent(imageFileName)
                try? FileManager.default.copyItem(at: sharedImageURL, to: localURL)
                thumbnailURL = "SavedImages/\(imageFileName)"
            }

            let item = CraftItem(
                title: shared.title ?? "Knutselidee",
                urlString: shared.urlString,
                thumbnailURLString: thumbnailURL,
                sourcePlatform: shared.sourcePlatform
            )
            modelContext.insert(item)

            if thumbnailURL == nil {
                itemsNeedingThumbnails.append((item, shared.urlString))
            }
        }

        SharedDataManager.clearPendingItems()
        try? modelContext.save()

        if !itemsNeedingThumbnails.isEmpty {
            let thumbnailRequests = itemsNeedingThumbnails.map { (item, urlString) in
                (item.persistentModelID, urlString)
            }
            Task {
                for (itemID, urlString) in thumbnailRequests {
                    if let metadata = await LinkMetadataService.shared.fetchAndSaveThumbnail(for: urlString) {
                        await MainActor.run { [itemID] in
                            if let localPath = metadata.localImagePath {
                                let fetchedItem = modelContext.model(for: itemID) as? CraftItem
                                fetchedItem?.thumbnailURLString = localPath
                                try? modelContext.save()
                            }
                        }
                    }
                }
            }
        }
    }

    static func generateThumbnailURL(for urlString: String) -> String? {
        let lowered = urlString.lowercased()

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

// MARK: - Masonry Grid
struct MasonryGrid: View {
    let items: [CraftItem]
    let onItemClick: (CraftItem) -> Void

    private let heights: [CGFloat] = [200, 160, 170, 220, 180, 210, 170, 200, 230, 170]

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            LazyVStack(spacing: 8) {
                ForEach(Array(leftColumn.enumerated()), id: \.element.id) { index, item in
                    CraftItemCard(item: item, height: heights[safe: index * 2] ?? 180)
                        .onTapGesture { onItemClick(item) }
                }
            }
            LazyVStack(spacing: 8) {
                ForEach(Array(rightColumn.enumerated()), id: \.element.id) { index, item in
                    CraftItemCard(item: item, height: heights[safe: index * 2 + 1] ?? 170)
                        .onTapGesture { onItemClick(item) }
                }
            }
            .padding(.top, 24)
        }
    }

    private var leftColumn: [CraftItem] {
        items.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
    }

    private var rightColumn: [CraftItem] {
        items.enumerated().compactMap { $0.offset % 2 == 1 ? $0.element : nil }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Filter Chip (redesigned)
struct SSFilterChip: View {
    let label: String
    let isActive: Bool
    var platformColor: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let color = platformColor, !isActive {
                    Circle()
                        .fill(color)
                        .frame(width: 7, height: 7)
                }
                Text(label)
                    .font(.system(size: 13, weight: isActive ? .semibold : .medium))
            }
            .foregroundStyle(isActive ? .white : Theme.ink)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(isActive ? Theme.primary : Theme.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isActive ? Theme.primary : Theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Platform Badge
struct PlatformBadge: View {
    let name: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
            Text(name)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Theme.inkMute)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
