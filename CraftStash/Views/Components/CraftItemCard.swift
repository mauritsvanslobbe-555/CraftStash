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
        VStack(alignment: .leading, spacing: 8) {
            thumbnailView
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.bold())
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                HStack {
                    Image(systemName: item.platformIcon)
                        .font(.caption2)
                    Text(item.sourcePlatform)
                        .font(.caption2)

                    Spacer()

                    if item.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundStyle(Theme.color(for: "berry"))
                    }
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: Theme.cardShadowRadius, y: 2)
        )
    }

    private var horizontalCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            thumbnailView
                .frame(width: 200, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.title)
                .font(.caption.bold())
                .lineLimit(2)
                .foregroundStyle(.primary)
                .frame(width: 200, alignment: .leading)

            HStack(spacing: 4) {
                Image(systemName: item.platformIcon)
                Text(item.sourcePlatform)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: Theme.cardShadowRadius, y: 2)
        )
    }

    private var thumbnailView: some View {
        ZStack {
            Rectangle()
                .fill(platformGradient)

            if let thumbnailURL = item.thumbnailURL {
                if thumbnailURL.isFileURL {
                    // Local image (screenshot)
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
                        }
                    }
                }
            } else {
                placeholderIcon
            }

            if item.isVideo {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
            }
        }
    }

    private var placeholderIcon: some View {
        VStack(spacing: 4) {
            Image(systemName: item.isVideo ? "play.rectangle.fill" : "photo.fill")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.8))
            Text(item.sourcePlatform)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var platformGradient: LinearGradient {
        let colors: [Color]
        switch item.sourcePlatform.lowercased() {
        case "youtube":
            colors = [Color.red, Color.red.opacity(0.7)]
        case "pinterest":
            colors = [Theme.color(for: "berry"), Theme.color(for: "coral")]
        case "instagram":
            colors = [.purple, .pink, .orange]
        case "tiktok":
            colors = [.black, Color(red: 0.0, green: 0.96, blue: 0.88)]
        case "screenshot":
            colors = [Theme.color(for: "forest"), Theme.color(for: "mint")]
        default:
            colors = [Theme.color(for: "ocean"), Theme.color(for: "sky")]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
