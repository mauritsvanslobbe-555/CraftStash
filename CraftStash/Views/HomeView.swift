import SwiftUI
import SwiftData
import PhotosUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    @Query(sort: \CraftItem.dateAdded, order: .reverse) private var items: [CraftItem]
    @State private var searchText = ""
    @State private var selectedItem: CraftItem?
    @State private var showingImportSheet = false
    @State private var showingImagePicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var activeFilter = "all"
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    private var filterOptions: [(id: String, label: String)] {
        [
            ("all", L.filterAll),
            ("videos", L.filterVideos),
            ("photos", L.filterPhotos),
            ("YouTube", "YouTube"),
            ("Instagram", "Instagram"),
            ("TikTok", "TikTok"),
            ("Pinterest", "Pinterest")
        ]
    }

    var filteredItems: [CraftItem] {
        var result = items

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.sourcePlatform.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch activeFilter {
        case "videos":
            result = result.filter { $0.isVideo }
        case "photos":
            result = result.filter { !$0.isVideo }
        case "all":
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
                    Text(L.appName)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        languageSwitchButton
                        Menu {
                            Button {
                                showingImportSheet = true
                            } label: {
                                Label(L.addLink, systemImage: "link.badge.plus")
                            }
                            Button {
                                showingImagePicker = true
                            } label: {
                                Label(L.saveScreenshot, systemImage: "photo.on.rectangle.angled")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Theme.primaryColor)
                        }
                    }
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchText, prompt: L.searchPlaceholder)
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

    // MARK: - Language Switch
    private var languageSwitchButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                languageManager.current = languageManager.current == .nl ? .en : .nl
            }
        } label: {
            Text(languageManager.current == .nl ? "🇬🇧" : "🇳🇱")
                .font(.title3)
        }
    }

    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !hasSeenWelcome {
                    welcomeBanner
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }

                HStack {
                    Text("\(items.count) \(L.itemsCount)")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filterOptions, id: \.id) { filter in
                            FilterChip(label: filter.label, isActive: activeFilter == filter.id) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    activeFilter = filter.id
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
                .padding(.bottom, 12)

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
                Text(L.tipTitle)
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
            Text(L.tipDesc)
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

    // MARK: - Onboarding
    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero with slogan
                VStack(spacing: 8) {
                    Text("✨")
                        .font(.system(size: 40))
                    Text(L.sloganTitle)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(L.sloganSubtitle)
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(Theme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // What is StuffStash
                VStack(alignment: .leading, spacing: 12) {
                    Text(L.howItWorks)
                        .font(.caption.bold())
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(0.5)
                        .padding(.horizontal)

                    onboardingStep(
                        num: "1",
                        icon: "square.and.arrow.up",
                        title: L.onboardStep1Title,
                        desc: L.onboardStep1Desc
                    )
                    onboardingStep(
                        num: "2",
                        icon: "arrowshape.turn.up.right.fill",
                        title: L.onboardStep2Title,
                        desc: L.onboardStep2Desc
                    )
                    onboardingStep(
                        num: "3",
                        icon: "checkmark.circle.fill",
                        title: L.onboardStep3Title,
                        desc: L.onboardStep3Desc
                    )
                }

                // Supported platforms
                VStack(spacing: 12) {
                    Text(L.worksWithTitle)
                        .font(.caption.bold())
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(0.5)

                    HStack(spacing: 20) {
                        PlatformBadge(name: "YouTube", color: .red)
                        PlatformBadge(name: "Instagram", color: .purple)
                        PlatformBadge(name: "TikTok", color: Theme.color(for: "sky"))
                        PlatformBadge(name: "Pinterest", color: Theme.color(for: "berry"))
                    }

                    Text(L.worksWithFooter)
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
                            Text(L.addLink)
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
                            Text(L.saveScreenshot)
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
                        title: L.screenshotTitle,
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
                thumbnailURL = localURL.absoluteString
            }

            let item = CraftItem(
                title: shared.title ?? L.defaultItemTitle,
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
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isActive ? Theme.primaryColor : Theme.surface2)
                .foregroundStyle(isActive ? .white : Theme.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isActive ? Theme.primaryColor : Theme.borderColor, lineWidth: 1)
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
                .frame(width: 12, height: 12)
            Text(name)
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

#Preview {
    HomeView()
        .environment(LanguageManager.shared)
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
