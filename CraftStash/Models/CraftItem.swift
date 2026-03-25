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
