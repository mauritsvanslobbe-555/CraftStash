import SwiftUI
import UIKit

struct CraftItemCard: View {
    let item: CraftItem
    var style: CardStyle = .grid
    var height: CGFloat = 180
    var tilt: Double = 0

    enum CardStyle {
        case grid, horizontal
    }

    var body: some View {
        switch style {
        case .grid:
            gridCard
        case .horizontal:
            horizontalCard
        }
    }

    // MARK: - Grid Card (new design)
    private var gridCard: some View {
        VStack(spacing: 0) {
            // Image area
            ZStack(alignment: .topLeading) {
                thumbnailView
                    .frame(height: height)
                    .clipped()

                // Platform badge (top-left)
                platformBadge
                    .padding(8)

                // Video duration badge (bottom-right)
                if item.isVideo {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 8))
                                Text("0:48")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.55))
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(8)
                        }
                    }
                }

                // Favorite heart (top-right)
                if item.isFavorite {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.rose)
                        }
                    }
                    .padding(8)
                }
            }

            // Title + date area
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                    .lineSpacing(1)

                HStack(spacing: 6) {
                    Text(item.dateAdded, style: .date)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.inkDim)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
        .rotationEffect(.degrees(tilt))
        .shadow(color: tilt != 0 ? .black.opacity(0.3) : .clear, radius: tilt != 0 ? 8 : 0, y: 4)
    }

    // MARK: - Horizontal Card
    private var horizontalCard: some View {
        ZStack(alignment: .bottomLeading) {
            thumbnailView
                .frame(width: 200, height: 140)

            platformBadge
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(item.sourcePlatform)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadiusSm))
        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
    }

    // MARK: - Platform Badge
    private var platformBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Theme.platformColor(for: item.sourcePlatform))
                .frame(width: 10, height: 10)
            Text(item.sourcePlatform)
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(.white)
                .textCase(.none)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.black.opacity(0.55))
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Thumbnail
    private var thumbnailView: some View {
        ZStack {
            // Platform gradient background
            Rectangle()
                .fill(Theme.platformGradient(for: item.sourcePlatform))

            if let thumbnailURL = item.thumbnailURL {
                if thumbnailURL.isFileURL {
                    if let data = try? Data(contentsOf: thumbnailURL),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholderIcon
                    }
                } else {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderIcon
                        default:
                            ProgressView()
                                .tint(.white)
                        }
                    }
                }
            } else {
                placeholderIcon
            }
        }
    }

    private var placeholderIcon: some View {
        VStack(spacing: 6) {
            Image(systemName: item.isVideo ? "play.rectangle.fill" : "photo.fill")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.8))
            Text(item.sourcePlatform)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}
