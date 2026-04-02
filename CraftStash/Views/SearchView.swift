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

                ScrollView {
                    VStack(spacing: 0) {
                        // Search bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Theme.textTertiary)
                            TextField("Zoek in je stash...", text: $query)
                                .foregroundStyle(.white)
                                .autocorrectionDisabled()
                            if !query.isEmpty {
                                Button {
                                    query = ""
                                    activeTag = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Theme.textTertiary)
                                }
                            }
                        }
                        .padding(14)
                        .background(Theme.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm)
                                .stroke(Theme.borderColor, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)

                        if query.isEmpty {
                            emptySearchView
                        } else {
                            searchResultsView
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Zoeken")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedItem) { item in
                CraftItemDetailView(item: item)
            }
        }
    }

    private var emptySearchView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Trending tags
            VStack(alignment: .leading, spacing: 10) {
                Text("POPULAIRE TAGS")
                    .font(.caption.bold())
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)

                FlowLayout(spacing: 8) {
                    ForEach(trendingTags, id: \.self) { tag in
                        Button {
                            activeTag = tag
                            query = tag
                        } label: {
                            Text(tag)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(activeTag == tag ? Theme.primaryColor.opacity(0.15) : Theme.surface2)
                                .foregroundStyle(activeTag == tag ? Theme.accentLight : Theme.textSecondary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(activeTag == tag ? Theme.primaryColor : Theme.borderColor, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Platforms
            VStack(alignment: .leading, spacing: 10) {
                Text("PLATFORMEN")
                    .font(.caption.bold())
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)

                VStack(spacing: 2) {
                    ForEach(["YouTube", "Instagram", "TikTok", "Pinterest"], id: \.self) { platform in
                        Button {
                            query = platform
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Theme.platformColor(for: platform))
                                    .frame(width: 8, height: 8)
                                Text(platform)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                Spacer()
                                let count = items.filter { $0.sourcePlatform.localizedCaseInsensitiveContains(platform) }.count
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textTertiary)
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(Theme.textTertiary)
                            }
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        Divider()
                            .overlay(Theme.borderColor)
                    }
                }
            }
        }
        .padding()
        .padding(.top, 8)
    }

    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(searchResults.count) resultaten")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)

            if searchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.textTertiary)
                    Text("Geen resultaten")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Probeer een andere zoekterm")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                MasonryGrid(items: searchResults) { item in
                    selectedItem = item
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
