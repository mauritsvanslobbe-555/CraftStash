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
                    collectionsListView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Collecties")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.caption.bold())
                            Text("Nieuw")
                                .font(.caption.bold())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.primaryColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                }
            }
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showingAddSheet) {
                AddCollectionSheet()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "folder.fill.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(Theme.primaryColor)

            Text("Maak je eerste collectie!")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Organiseer je knutselideeën in\ngroepen zoals 'Kerst', 'Verjaardag'\nof 'Makkelijk'")
                .font(.callout)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddSheet = true
            } label: {
                Label("Nieuwe collectie", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.accentGradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    private var collectionsListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(collections.count) collecties")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal)

                LazyVGrid(columns: Theme.gridColumns, spacing: 12) {
                    ForEach(collections) { collection in
                        NavigationLink(destination: CollectionDetailView(collection: collection)) {
                            CollectionCard(collection: collection)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(collection)
                            } label: {
                                Label("Verwijderen", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 12)
        }
    }
}

struct CollectionCard: View {
    let collection: CraftCollection

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background: thumbnail image or color gradient
            if let thumbnailURL = collection.thumbnailURL,
               let data = try? Data(contentsOf: thumbnailURL),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
            } else {
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.color(for: collection.colorName).opacity(0.8),
                                Theme.color(for: collection.colorName).opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)

                // Icon only when no thumbnail
                Image(systemName: collection.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.3))
                    .offset(x: 40, y: -40)
            }

            // Bottom gradient
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text("\(collection.itemCount) items")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Circle()
                            .fill(Theme.color(for: collection.colorName))
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // Color accent line at bottom
            VStack {
                Spacer()
                Rectangle()
                    .fill(Theme.color(for: collection.colorName))
                    .frame(height: 3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
    }
}

#Preview {
    CollectionsView()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
