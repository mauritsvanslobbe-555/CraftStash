import Foundation
import SwiftData

@Model
final class CraftCollection {
    var id: UUID
    var name: String
    var icon: String
    var colorName: String
    var dateCreated: Date

    var items: [CraftItem]?

    var itemCount: Int {
        items?.count ?? 0
    }

    init(name: String, icon: String = "folder.fill", colorName: String = "coral") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorName = colorName
        self.dateCreated = Date()
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
