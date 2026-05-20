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
            ZStack {
                // Dimmed background
                Theme.bg.opacity(0.65).ignoresSafeArea()
                    .background(.ultraThinMaterial)

                // Bottom sheet
                VStack(spacing: 0) {
                    Spacer(minLength: 100)

                    VStack(spacing: 0) {
                        // Handle bar
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.inkFaint)
                            .frame(width: 36, height: 4)
                            .padding(.top, 12)
                            .padding(.bottom, 14)

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                // Preview image
                                previewImage
                                    .padding(.horizontal, 20)

                                // Title + meta
                                titleSection
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)

                                // Tags
                                tagsSection
                                    .padding(.horizontal, 20)
                                    .padding(.top, 14)

                                // Open button
                                openButton
                                    .padding(.horizontal, 20)
                                    .padding(.top, 18)

                                // Action buttons
                                actionButtons
                                    .padding(.horizontal, 20)
                                    .padding(.top, 10)

                                // Notes
                                notesSection
                                    .padding(.horizontal, 20)
                                    .padding(.top, 14)

                                // Delete button
                                deleteButton
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                                    .padding(.bottom, 32)
                            }
                        }
                    }
                    .background(Theme.surfaceLo)
                    .clipShape(
                        RoundedCornerShape(radius: 28, corners: [.topLeft, .topRight])
                    )
                    .overlay(alignment: .top) {
                        RoundedCornerShape(radius: 28, corners: [.topLeft, .topRight])
                            .stroke(Theme.borderHi, lineWidth: 1)
                            .frame(height: 1)
                    }
                    .shadow(color: .black.opacity(0.5), radius: 30, y: -10)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCollectionPicker) {
                CollectionPickerSheet(item: item)
            }
        }
    }

    // MARK: - Preview Image
    private var previewImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.surface)
                .frame(height: 220)

            if let thumbnailURL = item.thumbnailURL, thumbnailURL.isFileURL {
                if let data = try? Data(contentsOf: thumbnailURL),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            } else if let thumbnailURL = item.thumbnailURL {
                AsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                } placeholder: {
                    ProgressView()
                        .tint(.white)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: item.isVideo ? "play.circle.fill" : "photo.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Theme.primarySoft)
                    Text(item.sourcePlatform)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.inkMute)
                }
            }

            // Play overlay for video
            if item.isVideo {
                Circle()
                    .fill(.black.opacity(0.5))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    )
            }

            // Platform badge top-left
            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Theme.platformColor(for: item.sourcePlatform))
                            .frame(width: 12, height: 12)
                        Text(item.sourcePlatform)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.55))
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    Spacer()
                }
                Spacer()
            }
            .padding(12)
        }
        .frame(height: 220)
        .onTapGesture {
            if let url = item.url, !url.isFileURL {
                UIApplication.shared.open(url)
            }
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.ink)
                .lineSpacing(1)

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.inkDim)
                Text(item.dateAdded, style: .date)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.inkMute)

                if let itemCollections = item.collections, let first = itemCollections.first {
                    Text("\u{00B7}")
                        .foregroundStyle(Theme.inkMute)
                    Text("uit \(first.name)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.inkMute)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Tags Section
    private var tagsSection: some View {
        FlowLayout(spacing: 6) {
            if let itemCollections = item.collections {
                ForEach(itemCollections) { collection in
                    HStack(spacing: 4) {
                        Image(systemName: collection.icon)
                            .font(.system(size: 10))
                        Text(collection.name)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.inkMute)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Open Button
    private var openButton: some View {
        Group {
            if let url = item.url, !url.isFileURL {
                Link(destination: url) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 15))
                        Text("Open op \(item.sourcePlatform)")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Theme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Theme.primary.opacity(0.4), radius: 12, y: 4)
                }
            }
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 8) {
            // Favorite
            actionCard(
                icon: item.isFavorite ? "heart.fill" : "heart",
                label: "Favoriet",
                color: Theme.rose,
                isActive: item.isFavorite
            ) {
                item.isFavorite.toggle()
            }

            // Collection
            actionCard(
                icon: "folder.badge.plus",
                label: "Collectie",
                color: Theme.primarySoft
            ) {
                showingCollectionPicker = true
            }

            // Share
            actionCard(
                icon: "square.and.arrow.up",
                label: "Delen",
                color: Theme.warm
            ) {
                shareItem()
            }
        }
    }

    private func actionCard(icon: String, label: String, color: Color, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(isActive ? color : color)
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.ink)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.inkMute)
                    Text("NOTITIE")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.inkDim)
                        .tracking(1)
                }
                Spacer()
                Button {
                    isEditingNotes.toggle()
                } label: {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.primarySoft)
                }
            }

            if isEditingNotes {
                TextField("Voeg een notitie toe...", text: Binding(
                    get: { item.notes ?? "" },
                    set: { item.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .font(.system(size: 13))
                .foregroundStyle(Theme.ink)
                .lineLimit(3...6)
                .padding(12)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.border, lineWidth: 1)
                )
            } else {
                Text(item.notes ?? "Nog geen notities")
                    .font(.system(size: 13))
                    .foregroundStyle(item.notes == nil ? Theme.inkDim : Theme.ink)
                    .lineSpacing(3)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.border, lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Delete Button
    private var deleteButton: some View {
        Button {
            modelContext.delete(item)
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                Text("Verwijder item")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(Theme.coral)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.coral.opacity(0.3), lineWidth: 1)
            )
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

// MARK: - Rounded Corner Shape (for top-only rounding)
struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
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
