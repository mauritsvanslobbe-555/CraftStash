import SwiftUI
import UIKit

struct CraftItemCard: View {
    let item: CraftItem
    let style: CardStyle

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

    private var gridCard: some View {
        ZStack(alignment: .topLeading) {
            thumbnailView
                .frame(minHeight: 160, maxHeight: 260)

            // Platform badge top-left
            platformBadge
                .padding(8)

            // Bottom gradient overlay with title
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(item.sourcePlatform)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // Video play button
            if item.isVideo {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
            }

            // Favorite indicator
            if item.isFavorite {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(Theme.danger)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(8)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm))
        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
    }

    private var horizontalCard: some View {
        ZStack(alignment: .bottomLeading) {
            thumbnailView
                .frame(width: 200, height: 140)

            platformBadge
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(item.sourcePlatform)
                    .font(.caption2)
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
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadiusSm))
        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
    }

    private var platformBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Theme.platformColor(for: item.sourcePlatform))
                .frame(width: 6, height: 6)
            Text(item.sourcePlatform)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.black.opacity(0.6))
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var thumbnailView: some View {
        ZStack {
            Rectangle()
                .fill(platformGradient)

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

    private var platformGradient: LinearGradient {
        let colors: [Color]
        switch item.sourcePlatform.lowercased() {
        case "youtube":
            colors = [Color.red.opacity(0.8), Color.red.opacity(0.4)]
        case "pinterest":
            colors = [Theme.color(for: "berry").opacity(0.8), Theme.color(for: "coral").opacity(0.4)]
        case "instagram":
            colors = [.purple.opacity(0.8), .pink.opacity(0.4), .orange.opacity(0.4)]
        case "tiktok":
            colors = [.black, Color(red: 0.0, green: 0.96, blue: 0.88).opacity(0.4)]
        case "screenshot":
            colors = [Theme.color(for: "forest").opacity(0.8), Theme.color(for: "mint").opacity(0.4)]
        default:
            colors = [Theme.primaryColor.opacity(0.8), Theme.primaryColor.opacity(0.3)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
