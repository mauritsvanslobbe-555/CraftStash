import SwiftUI
import SwiftData

struct AddItemsToCollectionSheet: View {
    let collection: CraftCollection
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftItem.dateAdded, order: .reverse) private var allItems: [CraftItem]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if allItems.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.primarySoft)

                        Text("Geen ideeën")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.ink)

                        Text("Deel eerst knutselideeën naar StuffStash")
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.inkMute)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(allItems) { item in
                                Button {
                                    toggleItem(item)
                                } label: {
                                    HStack(spacing: 12) {
                                        // Thumbnail
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Theme.surface)
                                                .frame(width: 44, height: 44)

                                            if let thumbnailURL = item.thumbnailURL, thumbnailURL.isFileURL,
                                               let data = try? Data(contentsOf: thumbnailURL),
                                               let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 44, height: 44)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            } else {
                                                Image(systemName: item.isVideo ? "play.circle.fill" : "photo.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundStyle(Theme.inkDim)
                                            }
                                        }
                                        .frame(width: 44, height: 44)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(item.title)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(Theme.ink)
                                                .lineLimit(1)

                                            HStack(spacing: 5) {
                                                Circle()
                                                    .fill(Theme.platformColor(for: item.sourcePlatform))
                                                    .frame(width: 8, height: 8)
                                                Text(item.sourcePlatform)
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(Theme.inkDim)
                                            }
                                        }

                                        Spacer()

                                        if isInCollection(item) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundStyle(Theme.color(for: collection.colorName))
                                        } else {
                                            Circle()
                                                .stroke(Theme.border, lineWidth: 1.5)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                }
                                .buttonStyle(.plain)

                                if item.id != allItems.last?.id {
                                    Rectangle()
                                        .fill(Theme.border)
                                        .frame(height: 1)
                                        .padding(.leading, 76)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Ideeën toevoegen")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Klaar")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.primary)
                    }
                }
            }
        }
    }

    private func isInCollection(_ item: CraftItem) -> Bool {
        collection.items?.contains(where: { $0.id == item.id }) ?? false
    }

    private func toggleItem(_ item: CraftItem) {
        if isInCollection(item) {
            collection.items?.removeAll(where: { $0.id == item.id })
        } else {
            if collection.items == nil {
                collection.items = []
            }
            collection.items?.append(item)
        }
        try? modelContext.save()
    }
}
