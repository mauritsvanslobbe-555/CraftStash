import Foundation
import LinkPresentation

actor LinkMetadataService {
    static let shared = LinkMetadataService()

    private var cache: [String: CachedMetadata] = [:]

    struct CachedMetadata: Sendable {
        let title: String?
        let imageURL: URL?
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
                imageURL: metadata.imageProvider != nil ? url : nil
            )
            cache[urlString] = result
            return result
        } catch {
            return nil
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
