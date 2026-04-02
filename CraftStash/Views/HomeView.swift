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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("CraftStash")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
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
                            .foregroundStyle(Theme.primaryColor)
                    }
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Zoek in je stash...")
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

    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Welcome banner
                if !hasSeenWelcome {
                    welcomeBanner
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }

                // Stats
                HStack {
                    Text("\(items.count) items opgeslagen")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            FilterChip(label: filter, isActive: activeFilter == filter) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    activeFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 12)

                // Masonry Grid
                MasonryGrid(items: filteredItems) { item in
                    selectedItem = item
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Welcome Banner
    private var welcomeBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Tip: Zo bewaar je ideeën")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    withAnimation { hasSeenWelcome = true }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            Text("Zie je een leuk knutselfilmpje of -plaatje? Tik op de deel-knop en kies CraftStash!")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .background(Theme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.borderColor, lineWidth: 1)
        )
    }

    // MARK: - Onboarding (shown until first item is saved)
    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero
                VStack(spacing: 8) {
                    Text("✨")
                        .font(.system(size: 40))
                    Text("Welkom bij CraftStash!")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("Bewaar al je knutselideeën\nop één plek.")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(Theme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Steps
                VStack(alignment: .leading, spacing: 12) {
                    Text("ZO WERKT HET")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(0.5)
                        .padding(.horizontal)

                    onboardingStep(
                        num: "1",
                        icon: "square.and.arrow.up",
                        title: "Zie een leuk knutselidee",
                        desc: "Op YouTube, Instagram, TikTok, Pinterest of waar dan ook."
                    )
                    onboardingStep(
                        num: "2",
                        icon: "arrowshape.turn.up.right.fill",
                        title: "Tik op de deel-knop",
                        desc: "Kies 'CraftStash' in het deelmenu. Je kunt ook screenshots of foto's delen!"
                    )
                    onboardingStep(
                        num: "3",
                        icon: "checkmark.circle.fill",
                        title: "Opgeslagen!",
                        desc: "Je knutselidee staat veilig in CraftStash. Organiseer het in mappen en bekijk het wanneer je wilt."
                    )
                }

                // Supported platforms
                VStack(spacing: 12) {
                    Text("WERKT MET")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(0.5)

                    HStack(spacing: 20) {
                        PlatformBadge(name: "YouTube", color: .red)
                        PlatformBadge(name: "Instagram", color: .purple)
                        PlatformBadge(name: "TikTok", color: Theme.color(for: "sky"))
                        PlatformBadge(name: "Pinterest", color: Theme.color(for: "berry"))
                    }

                    Text("En alle andere apps met een deel-knop!")
                        .font(.caption)
                        .foregroundStyle(Theme.textTertiary)
                }
                .padding(.vertical, 8)

                // CTA buttons
                VStack(spacing: 12) {
                    Button {
                        showingImportSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "link.badge.plus")
                            Text("Link toevoegen")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accentGradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        showingImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Screenshot opslaan")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.surface2)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.borderColor, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
    }

    private func onboardingStep(num: String, icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.primaryColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundStyle(Theme.primaryColor)
            }
            .overlay(alignment: .topTrailing) {
                Text(num)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(Theme.primaryColor)
                    .clipShape(Circle())
                    .offset(x: 4, y: -4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Theme.surface1)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm)
                .stroke(Theme.borderColor, lineWidth: 1)
        )
        .padding(.horizontal)
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
            var thumbnailURL: String? = Self.generateThumbnailURL(for: shared.urlString)

            // If shared item has an image file, copy it and use as thumbnail
            if let imageFileName = shared.imageFileName,
               let sharedImageURL = SharedDataManager.sharedImageURL(for: imageFileName) {
                let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let imageDir = docsURL.appendingPathComponent("SavedImages", isDirectory: true)
                try? FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
                let localURL = imageDir.appendingPathComponent(imageFileName)
                try? FileManager.default.copyItem(at: sharedImageURL, to: localURL)
                thumbnailURL = localURL.absoluteString
            }

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

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            LazyVStack(spacing: 10) {
                ForEach(leftColumn) { item in
                    CraftItemCard(item: item, style: .grid)
                        .onTapGesture { onItemClick(item) }
                }
            }
            LazyVStack(spacing: 10) {
                ForEach(rightColumn) { item in
                    CraftItemCard(item: item, style: .grid)
                        .onTapGesture { onItemClick(item) }
                }
            }
        }
    }

    private var leftColumn: [CraftItem] {
        items.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
    }

    private var rightColumn: [CraftItem] {
        items.enumerated().compactMap { $0.offset % 2 == 1 ? $0.element : nil }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isActive ? Theme.primaryColor : Theme.surface2)
                .foregroundStyle(isActive ? .white : Theme.textSecondary)
                .clipShape(Capsule())
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
                .frame(width: 12, height: 12)
            Text(name)
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
