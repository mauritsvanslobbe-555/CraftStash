import SwiftUI

struct AddItemManuallySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var urlText = ""
    @State private var title = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L.pasteLink, text: $urlText)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: urlText) { _, newValue in
                            if title.isEmpty && !newValue.isEmpty {
                                fetchTitle()
                            }
                        }
                } header: {
                    Text("Link")
                } footer: {
                    Text(L.linkFooter)
                }

                Section(L.titleLabel) {
                    TextField(L.titlePlaceholder, text: $title)
                }

                if isLoading {
                    Section {
                        HStack {
                            ProgressView()
                            Text(L.fetchingInfo)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(L.addLinkTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L.save) {
                        saveItem()
                    }
                    .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func fetchTitle() {
        guard URL(string: urlText) != nil else { return }
        isLoading = true

        Task {
            let platform = await LinkMetadataService.shared.detectPlatform(from: urlText)
            let metadata = await LinkMetadataService.shared.fetchMetadata(for: urlText)

            await MainActor.run {
                if title.isEmpty, let fetchedTitle = metadata?.title {
                    title = fetchedTitle
                }
                _ = platform
                isLoading = false
            }
        }
    }

    private func saveItem() {
        let url = urlText.trimmingCharacters(in: .whitespaces)
        let platform = detectPlatformSync(from: url)
        let itemTitle = title.isEmpty ? L.defaultItemTitle : title

        let youtubeThumbnail = HomeView.generateThumbnailURL(for: url)

        let item = CraftItem(
            title: itemTitle,
            urlString: url,
            thumbnailURLString: youtubeThumbnail,
            sourcePlatform: platform
        )
        modelContext.insert(item)
        try? modelContext.save()
        dismiss()

        if youtubeThumbnail == nil {
            let itemID = item.persistentModelID
            Task {
                if let metadata = await LinkMetadataService.shared.fetchAndSaveThumbnail(for: url) {
                    await MainActor.run { [itemID] in
                        if let localPath = metadata.localImagePath {
                            let fetchedItem = modelContext.model(for: itemID) as? CraftItem
                            fetchedItem?.thumbnailURLString = localPath
                            try? modelContext.save()
                        }
                    }
                }
            }
        }
    }

    private func detectPlatformSync(from url: String) -> String {
        let lowered = url.lowercased()
        if lowered.contains("youtube") || lowered.contains("youtu.be") { return "YouTube" }
        if lowered.contains("pinterest") { return "Pinterest" }
        if lowered.contains("instagram") { return "Instagram" }
        if lowered.contains("tiktok") { return "TikTok" }
        if lowered.contains("facebook") || lowered.contains("fb.watch") { return "Facebook" }
        return "Web"
    }
}

#Preview {
    AddItemManuallySheet()
        .modelContainer(for: CraftItem.self, inMemory: true)
}
