import SwiftUI
import SwiftData

struct CraftItemDetailView: View {
    @Bindable var item: CraftItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftCollection.name) private var collections: [CraftCollection]
    @State private var showingCollectionPicker = false
    @State private var isEditingNotes = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Thumbnail / Preview
                        ZStack {
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                .fill(Theme.surface2)
                                .frame(height: 240)

                            if let thumbnailURL = item.thumbnailURL, thumbnailURL.isFileURL {
                                if let data = try? Data(contentsOf: thumbnailURL),
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 240)
                                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                                }
                            } else if let thumbnailURL = item.thumbnailURL {
                                AsyncImage(url: thumbnailURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 240)
                                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                                } placeholder: {
                                    ProgressView()
                                        .tint(.white)
                                }
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: item.isVideo ? "play.circle.fill" : "photo.fill")
                                        .font(.system(size: 48))
                                        .foregroundStyle(Theme.primaryColor)
                                    Text(item.sourcePlatform)
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
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
                            if let url = item.url, !url.isFileURL {
                                UIApplication.shared.open(url)
                            }
                        }

                        // Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text(item.title)
                                .font(.title2.bold())
                                .foregroundStyle(.white)

                            HStack {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Theme.platformColor(for: item.sourcePlatform))
                                        .frame(width: 8, height: 8)
                                    Text(item.sourcePlatform)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.textSecondary)
                                }

                                Spacer()

                                Text(item.dateAdded, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(Theme.textTertiary)
                            }

                            Divider().overlay(Theme.borderColor)

                            // Actions
                            HStack(spacing: 24) {
                                actionButton(
                                    icon: item.isFavorite ? "heart.fill" : "heart",
                                    label: L.favorite,
                                    color: Theme.danger,
                                    isActive: item.isFavorite
                                ) {
                                    item.isFavorite.toggle()
                                }

                                actionButton(
                                    icon: "folder.badge.plus",
                                    label: L.collection,
                                    color: Theme.primaryColor
                                ) {
                                    showingCollectionPicker = true
                                }

                                actionButton(
                                    icon: "square.and.arrow.up",
                                    label: L.share,
                                    color: Theme.success
                                ) {
                                    shareItem()
                                }

                                if let url = item.url, !url.isFileURL {
                                    Link(destination: url) {
                                        VStack(spacing: 4) {
                                            Image(systemName: "arrow.up.right.square")
                                                .font(.title3)
                                                .foregroundStyle(Theme.accentLight)
                                            Text(L.open)
                                                .font(.caption2)
                                                .foregroundStyle(Theme.textSecondary)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)

                            Divider().overlay(Theme.borderColor)

                            // Notes
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(L.notes)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Button(isEditingNotes ? L.done : L.edit) {
                                        isEditingNotes.toggle()
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.primaryColor)
                                }

                                if isEditingNotes {
                                    TextField(L.addNotes, text: Binding(
                                        get: { item.notes ?? "" },
                                        set: { item.notes = $0.isEmpty ? nil : $0 }
                                    ), axis: .vertical)
                                    .padding(12)
                                    .background(Theme.surface2)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(.white)
                                    .lineLimit(3...6)
                                } else {
                                    Text(item.notes ?? L.noNotes)
                                        .font(.body)
                                        .foregroundStyle(item.notes == nil ? Theme.textTertiary : .white)
                                }
                            }

                            // Collections
                            if let itemCollections = item.collections, !itemCollections.isEmpty {
                                Divider().overlay(Theme.borderColor)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(L.inCollections)
                                        .font(.headline)
                                        .foregroundStyle(.white)
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

                            Divider().overlay(Theme.borderColor)

                            // Delete button
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text(L.deleteItem)
                                }
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.danger.opacity(0.1))
                                .foregroundStyle(Theme.danger)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.danger.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(L.detail)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showingCollectionPicker) {
                CollectionPickerSheet(item: item)
            }
            .alert(L.deleteItem, isPresented: $showingDeleteConfirmation) {
                Button(L.cancel, role: .cancel) { }
                Button(L.delete, role: .destructive) {
                    deleteItem()
                }
            } message: {
                Text(L.deleteItemConfirm)
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
                    .foregroundStyle(isActive ? color : Theme.textSecondary)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
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

    private func deleteItem() {
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
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
