import SwiftUI
import SwiftData

struct CraftItemDetailView: View {
    @Bindable var item: CraftItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftCollection.name) private var collections: [CraftCollection]
    @State private var showingCollectionPicker = false
    @State private var isEditingNotes = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Thumbnail / Preview
                    ZStack {
                        RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 240)

                        if let thumbnailURL = item.thumbnailURL {
                            AsyncImage(url: thumbnailURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 240)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: item.isVideo ? "play.circle.fill" : "photo.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Theme.color(for: "coral"))
                                Text(item.sourcePlatform)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if item.isVideo {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                        }
                    }
                    .onTapGesture {
                        if let url = item.url {
                            UIApplication.shared.open(url)
                        }
                    }

                    // Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(item.title)
                            .font(.title2.bold())

                        HStack {
                            Label(item.sourcePlatform, systemImage: item.platformIcon)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(item.dateAdded, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        // Actions
                        HStack(spacing: 24) {
                            actionButton(
                                icon: item.isFavorite ? "heart.fill" : "heart",
                                label: "Favoriet",
                                color: Theme.color(for: "berry"),
                                isActive: item.isFavorite
                            ) {
                                item.isFavorite.toggle()
                            }

                            actionButton(
                                icon: "folder.badge.plus",
                                label: "Collectie",
                                color: Theme.color(for: "ocean")
                            ) {
                                showingCollectionPicker = true
                            }

                            actionButton(
                                icon: "square.and.arrow.up",
                                label: "Deel",
                                color: Theme.color(for: "forest")
                            ) {
                                shareItem()
                            }

                            if let url = item.url {
                                Link(destination: url) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.title3)
                                            .foregroundStyle(Theme.color(for: "lavender"))
                                        Text("Open")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Divider()

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Notities")
                                    .font(.headline)
                                Spacer()
                                Button(isEditingNotes ? "Klaar" : "Bewerk") {
                                    isEditingNotes.toggle()
                                }
                                .font(.subheadline)
                            }

                            if isEditingNotes {
                                TextField("Voeg notities toe...", text: Binding(
                                    get: { item.notes ?? "" },
                                    set: { item.notes = $0.isEmpty ? nil : $0 }
                                ), axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                            } else {
                                Text(item.notes ?? "Geen notities")
                                    .font(.body)
                                    .foregroundStyle(item.notes == nil ? .tertiary : .primary)
                            }
                        }

                        // Collections this item belongs to
                        if let itemCollections = item.collections, !itemCollections.isEmpty {
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("In collecties")
                                    .font(.headline)
                                FlowLayout(spacing: 8) {
                                    ForEach(itemCollections) { collection in
                                        HStack(spacing: 4) {
                                            Image(systemName: collection.icon)
                                            Text(collection.name)
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Theme.color(for: collection.colorName).opacity(0.15))
                                        .foregroundStyle(Theme.color(for: collection.colorName))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingCollectionPicker) {
                CollectionPickerSheet(item: item)
            }
        }
    }

    private func actionButton(
        icon: String,
        label: String,
        color: Color,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isActive ? color : .secondary)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func shareItem() {
        guard let url = item.url else { return }
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Flow Layout for collection tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
