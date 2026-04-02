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
        let imageFileName: String?
    }

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }

    static func savePendingItem(_ item: SharedItem) {
        var items = loadPendingItems()
        items.append(item)

        if let data = try? JSONEncoder().encode(items) {
            sharedDefaults?.set(data, forKey: pendingItemsKey)
        }
    }

    static func saveImageToSharedContainer(_ imageData: Data) -> String? {
        guard let containerURL = sharedContainerURL else { return nil }
        let imagesDir = containerURL.appendingPathComponent("SharedImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)

        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = imagesDir.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            return nil
        }
    }

    static func sharedImageURL(for fileName: String) -> URL? {
        guard let containerURL = sharedContainerURL else { return nil }
        return containerURL.appendingPathComponent("SharedImages").appendingPathComponent(fileName)
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
