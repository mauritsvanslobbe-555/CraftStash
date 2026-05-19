import SwiftUI
import SwiftData

struct CollectionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftCollection.dateCreated, order: .reverse) private var collections: [CraftCollection]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if collections.isEmpty {
                    emptyStateView
                } else {
                    collectionsGridView
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSheet) {
                AddCollectionSheet()
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("JOUW MAPPEN")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.inkDim)
                    .tracking(1)
                Text(L.collectionsTitle)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.ink)
            }
            Spacer()
            Button {
                showingAddSheet = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text(L.newItem)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(Theme.primary)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "folder.fill.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(Theme.primarySoft)

            Text(L.createFirstCollection)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.ink)

            Text(L.organizeIdeas)
                .font(.system(size: 13.5))
                .foregroundStyle(Theme.inkMute)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Button {
                showingAddSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text(L.newCollection)
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .frame(height: 46)
                .background(Theme.primary)
                .clipShape(Capsule())
                .shadow(color: Theme.primary.opacity(0.4), radius: 12, y: 4)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Grid View
    private var collectionsGridView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                headerView

                // Stats
                HStack(spacing: 6) {
                    Text("\(collections.count) \(L.collectionsCount)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.inkMute)
                    Circle()
                        .fill(Theme.inkDim)
                        .frame(width: 3, height: 3)
                    Text("\(collections.reduce(0) { $0 + $1.itemCount }) items")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.inkMute)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Featured first collection (big)
                if let first = collections.first {
                    NavigationLink(destination: CollectionDetailView(collection: first)) {
                        featuredCollectionCard(first)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            modelContext.delete(first)
                        } label: {
                            Label(L.delete, systemImage: "trash")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                // Grid of remaining collections
                LazyVGrid(columns: Theme.gridColumns, spacing: 10) {
                    ForEach(Array(collections.dropFirst())) { collection in
                        NavigationLink(destination: CollectionDetailView(collection: collection)) {
                            collectionTile(collection)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(collection)
                            } label: {
                                Label(L.delete, systemImage: "trash")
                            }
                        }
                    }

                    // "New collection" dashed tile
                    Button {
                        showingAddSheet = true
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 18))
                                .foregroundStyle(Theme.inkMute)
                            Text(L.newCollection)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.inkMute)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Theme.borderHi, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Featured Collection Card
    private func featuredCollectionCard(_ collection: CraftCollection) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.color(for: collection.colorName))
                .frame(height: 160)

            // Overlay gradient
            LinearGradient(
                colors: [Theme.color(for: collection.colorName).opacity(0.4), Theme.color(for: collection.colorName).opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(height: 160)

            // Large decorative icon
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: collection.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(16)
                }
                Spacer()
            }
            .frame(height: 160)

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text("MEEST GEBRUIKT")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.85))
                    .tracking(1)
                Text(collection.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Text("\(collection.itemCount) items")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(16)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Collection Tile
    private func collectionTile(_ collection: CraftCollection) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.color(for: collection.colorName))
                .frame(height: 130)

            LinearGradient(
                colors: [Theme.color(for: collection.colorName).opacity(0.35), Theme.color(for: collection.colorName).opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(height: 130)

            // Thumbnail if available
            if let thumbnailURL = collection.thumbnailURL,
               let data = try? Data(contentsOf: thumbnailURL),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .opacity(0.45)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(collection.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(collection.itemCount) ITEMS")
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .frame(height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    CollectionsView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
