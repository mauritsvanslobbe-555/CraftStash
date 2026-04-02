import Foundation
import LinkPresentation
import UIKit

actor LinkMetadataService {
    static let shared = LinkMetadataService()

    private var cache: [String: CachedMetadata] = [:]

    struct CachedMetadata: Sendable {
        let title: String?
        let imageURL: URL?
        let localImagePath: String?
    }

    /// Fetches metadata and downloads + saves the preview image locally
    func fetchAndSaveThumbnail(for urlString: String) async -> CachedMetadata? {
        if let cached = cache[urlString], cached.localImagePath != nil {
            return cached
        }

        guard let url = URL(string: urlString) else { return nil }

        let provider = LPMetadataProvider()
        provider.timeout = 15

        do {
            let metadata = try await provider.startFetchingMetadata(for: url)

            var localPath: String?

            // Try to extract and save the image
            if let imageProvider = metadata.imageProvider {
                localPath = await saveImageFromProvider(imageProvider)
            }

            let result = CachedMetadata(
                title: metadata.title,
                imageURL: url,
                localImagePath: localPath
            )
            cache[urlString] = result
            return result
        } catch {
            return nil
        }
    }

    func fetchMetadata(for urlString: String) async -> CachedMetadata? {
        if let cached = cache[urlString] {
            return cached
        }

        guard let url = URL(string: urlString) else { return nil }

        let provider = LPMetadataProvider()
        provider.timeout = 10

        do {
            let metadata = try await provider.startFetchingMetadata(for: url)
            let result = CachedMetadata(
                title: metadata.title,
                imageURL: metadata.imageProvider != nil ? url : nil,
                localImagePath: nil
            )
            cache[urlString] = result
            return result
        } catch {
            return nil
        }
    }

    private func saveImageFromProvider(_ provider: NSItemProvider) async -> String? {
        await withCheckedContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { object, error in
                guard let image = object as? UIImage,
                      let data = image.jpegData(compressionQuality: 0.7) else {
                    continuation.resume(returning: nil)
                    return
                }

                let fileName = "\(UUID().uuidString).jpg"
                let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let imageDir = docsURL.appendingPathComponent("Thumbnails", isDirectory: true)
                try? FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
                let fileURL = imageDir.appendingPathComponent(fileName)

                do {
                    try data.write(to: fileURL)
                    continuation.resume(returning: fileURL.absoluteString)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func detectPlatform(from urlString: String) -> String {
        let url = urlString.lowercased()

        if url.contains("youtube.com") || url.contains("youtu.be") {
            return "YouTube"
        } else if url.contains("pinterest") {
            return "Pinterest"
        } else if url.contains("instagram") {
            return "Instagram"
        } else if url.contains("tiktok") {
            return "TikTok"
        } else if url.contains("facebook") || url.contains("fb.watch") {
            return "Facebook"
        } else if url.contains("twitter") || url.contains("x.com") {
            return "X"
        } else if url.contains("vimeo") {
            return "Vimeo"
        } else if url.contains("reddit") {
            return "Reddit"
        } else if url.contains("tumblr") {
            return "Tumblr"
        } else {
            return "Web"
        }
    }
}
