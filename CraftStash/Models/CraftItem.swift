import Foundation
import SwiftData

@Model
final class CraftItem {
    var id: UUID
    var title: String
    var urlString: String
    var thumbnailURLString: String?
    var sourcePlatform: String
    var dateAdded: Date
    var isFavorite: Bool
    var notes: String?

    @Relationship(inverse: \CraftCollection.items)
    var collections: [CraftCollection]?

    var url: URL? {
        URL(string: urlString)
    }

    var thumbnailURL: URL? {
        guard let thumbnailURLString else { return nil }

        // If it's already a full http(s) URL, return as-is
        if thumbnailURLString.hasPrefix("http://") || thumbnailURLString.hasPrefix("https://") {
            return URL(string: thumbnailURLString)
        }

        // If it's a file:// URL, try it directly first
        if thumbnailURLString.hasPrefix("file://") {
            let directURL = URL(string: thumbnailURLString)
            if let directURL, FileManager.default.fileExists(atPath: directURL.path) {
                return directURL
            }
            // File doesn't exist at absolute path (container UUID changed after update)
            // Try to extract relative path and resolve against current Documents dir
            if let directURL {
                let pathComponents = directURL.pathComponents
                // Look for known directories: "Thumbnails", "SavedImages", "CollectionThumbnails"
                let knownDirs = ["Thumbnails", "SavedImages", "CollectionThumbnails"]
                for dir in knownDirs {
                    if let idx = pathComponents.firstIndex(of: dir),
                       idx + 1 < pathComponents.count {
                        let relativePath = pathComponents[idx...].joined(separator: "/")
                        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let resolvedURL = docsURL.appendingPathComponent(relativePath)
                        if FileManager.default.fileExists(atPath: resolvedURL.path) {
                            return resolvedURL
                        }
                    }
                }
            }
            return directURL
        }

        // If it's a relative path (e.g., "Thumbnails/UUID.jpg")
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let resolvedURL = docsURL.appendingPathComponent(thumbnailURLString)
        if FileManager.default.fileExists(atPath: resolvedURL.path) {
            return resolvedURL
        }

        // Last resort: try as URL string
        return URL(string: thumbnailURLString)
    }

    var platformIcon: String {
        switch sourcePlatform.lowercased() {
        case let p where p.contains("youtube"):
            return "play.rectangle.fill"
        case let p where p.contains("pinterest"):
            return "pin.fill"
        case let p where p.contains("instagram"):
            return "camera.fill"
        case let p where p.contains("tiktok"):
            return "music.note"
        case let p where p.contains("facebook"):
            return "person.2.fill"
        case let p where p.contains("screenshot"):
            return "camera.viewfinder"
        default:
            return "link"
        }
    }

    var isVideo: Bool {
        let videoKeywords = ["youtube", "youtu.be", "tiktok", "vimeo", "video", "reels", "shorts"]
        return videoKeywords.contains(where: { urlString.lowercased().contains($0) })
    }

    init(
        title: String,
        urlString: String,
        thumbnailURLString: String? = nil,
        sourcePlatform: String = "Onbekend",
        isFavorite: Bool = false,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.urlString = urlString
        self.thumbnailURLString = thumbnailURLString
        self.sourcePlatform = sourcePlatform
        self.dateAdded = Date()
        self.isFavorite = isFavorite
        self.notes = notes
        self.collections = []
    }
}
