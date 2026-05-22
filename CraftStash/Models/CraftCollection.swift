import Foundation
import SwiftData

@Model
final class CraftCollection {
    var id: UUID
    var name: String
    var icon: String
    var colorName: String
    var dateCreated: Date
    var thumbnailImagePath: String?

    var items: [CraftItem]?

    var itemCount: Int {
        items?.count ?? 0
    }

    var thumbnailURL: URL? {
        guard let thumbnailImagePath else { return nil }

        // If it's a file:// URL, try direct first, then resolve against current docs dir
        if thumbnailImagePath.hasPrefix("file://") {
            let directURL = URL(string: thumbnailImagePath)
            if let directURL, FileManager.default.fileExists(atPath: directURL.path) {
                return directURL
            }
            // Container UUID may have changed; extract relative path and resolve
            if let directURL {
                let pathComponents = directURL.pathComponents
                if let idx = pathComponents.firstIndex(of: "CollectionThumbnails"),
                   idx + 1 < pathComponents.count {
                    let relativePath = pathComponents[idx...].joined(separator: "/")
                    let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let resolvedURL = docsURL.appendingPathComponent(relativePath)
                    if FileManager.default.fileExists(atPath: resolvedURL.path) {
                        return resolvedURL
                    }
                }
            }
            return directURL
        }

        // Relative path
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let resolvedURL = docsURL.appendingPathComponent(thumbnailImagePath)
        if FileManager.default.fileExists(atPath: resolvedURL.path) {
            return resolvedURL
        }

        return URL(string: thumbnailImagePath)
    }

    init(name: String, icon: String = "folder.fill", colorName: String = "coral", thumbnailImagePath: String? = nil) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorName = colorName
        self.dateCreated = Date()
        self.thumbnailImagePath = thumbnailImagePath
        self.items = []
    }

    static let availableIcons = [
        "folder.fill", "star.fill", "heart.fill", "scissors",
        "paintbrush.fill", "pencil", "gift.fill", "leaf.fill",
        "sparkles", "wand.and.stars", "party.popper.fill",
        "birthday.cake.fill", "teddybear.fill", "figure.play",
        "sun.max.fill", "moon.fill", "cloud.fill", "snowflake",
        "flame.fill", "drop.fill"
    ]

    static let availableColors = [
        "coral", "ocean", "forest", "sunshine",
        "lavender", "mint", "berry", "sky"
    ]
}
