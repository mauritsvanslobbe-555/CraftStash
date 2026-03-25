import Foundation

/// Manages shared data between the main app and the share extension via App Groups.
enum SharedDataManager {
    static let appGroupIdentifier = "group.com.craftstash.shared"
    static let pendingItemsKey = "pendingSharedItems"

    struct SharedItem: Codable {
        let urlString: String
        let title: String?
        let sourcePlatform: String
        let dateAdded: Date
    }

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    static func savePendingItem(_ item: SharedItem) {
        var items = loadPendingItems()
        items.append(item)

        if let data = try? JSONEncoder().encode(items) {
            sharedDefaults?.set(data, forKey: pendingItemsKey)
        }
    }

    static func loadPendingItems() -> [SharedItem] {
        guard let data = sharedDefaults?.data(forKey: pendingItemsKey),
              let items = try? JSONDecoder().decode([SharedItem].self, from: data) else {
            return []
        }
        return items
    }

    static func clearPendingItems() {
        sharedDefaults?.removeObject(forKey: pendingItemsKey)
    }
}
