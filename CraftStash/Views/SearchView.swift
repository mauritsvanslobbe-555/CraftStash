import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftItem.dateAdded, order: .reverse) private var items: [CraftItem]
    @State private var query = ""
    @State private var selectedItem: CraftItem?
    @State private var activeTag: String?

    private let trendingTags = ["Kerst", "Verjaardag", "Papier", "Verf", "Makkelijk", "Moeilijk"]

    var searchResults: [CraftItem] {
        guard !query.isEmpty else { return [] }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.sourcePlatform.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text(L.searchTitle)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // Search bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15))
                                .foregroundStyle(query.isEmpty ? Theme.inkMute : Theme.primarySoft)
                            TextField("", text: $query, prompt: Text(L.searchPlaceholder).foregroundStyle(Theme.inkMute))
                                .font(.system(size: 14.5))
                                .foregroundStyle(Theme.ink)
                                .autocorrectionDisabled()
                                .tint(Theme.primary)
                            if !query.isEmpty {
                                Button {
                                    query = ""
                                    activeTag = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Theme.inkDim)
                                }
                            }
                        }
                        .frame(height: 44)
                        .padding(.horizontal, 16)
                        .background(query.isEmpty ? Theme.surface : Theme.surfaceHi)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(query.isEmpty ? Theme.border : Theme.primary.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        if query.isEmpty {
                            emptySearchView
                        } else {
                            searchResultsView
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedItem) { item in
                CraftItemDetailView(item: item)
            }
        }
    }

    private var emptySearchView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Trending tags
            VStack(alignment: .leading, spacing: 10) {
                Text(L.popularTags)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.inkDim)
                    .tracking(1)

                FlowLayout(spacing: 8) {
                    ForEach(trendingTags, id: \.self) { tag in
                        Button {
                            activeTag = tag
                            query = tag
                        } label: {
                            Text(tag)
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 14)
                                .frame(height: 34)
                                .background(activeTag == tag ? Theme.primaryTint : Theme.surface)
                                .foregroundStyle(activeTag == tag ? Theme.primarySoft : Theme.ink)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(activeTag == tag ? Theme.primary : Theme.border, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Platforms
            VStack(alignment: .leading, spacing: 10) {
                Text(L.platforms)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.inkDim)
                    .tracking(1)

                VStack(spacing: 0) {
                    ForEach(["YouTube", "Instagram", "TikTok", "Pinterest"], id: \.self) { platform in
                        Button {
                            query = platform
                        } label: {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Theme.platformColor(for: platform))
                                    .frame(width: 10, height: 10)
                                Text(platform)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                let count = items.filter { $0.sourcePlatform.localizedCaseInsensitiveContains(platform) }.count
                                Text("\(count)")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(Theme.inkDim)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.inkDim)
                            }
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)

                        if platform != "Pinterest" {
                            Rectangle()
                                .fill(Theme.border)
                                .frame(height: 1)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.border, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(searchResults.count) \(L.results)")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.inkMute)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            if searchResults.isEmpty {
                VStack(spacing: 8) {
                    Text("\u{1F50D}")
                        .font(.system(size: 56))
                        .padding(.bottom, 8)
                    Text(L.noResults)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text(L.tryDifferent)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.inkMute)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                MasonryGrid(items: searchResults) { item in
                    selectedItem = item
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
