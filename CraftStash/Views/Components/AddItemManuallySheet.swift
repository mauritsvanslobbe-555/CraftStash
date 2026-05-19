import SwiftUI

struct AddItemManuallySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var urlText = ""
    @State private var title = ""
    @State private var isLoading = false

    private var canSave: Bool {
        !urlText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // URL field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LINK")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundStyle(Theme.inkDim)
                                .tracking(1)

                            HStack(spacing: 10) {
                                Image(systemName: "link")
                                    .font(.system(size: 14))
                                    .foregroundStyle(urlText.isEmpty ? Theme.inkDim : Theme.primarySoft)

                                TextField("", text: $urlText, prompt: Text("Plak een link...").foregroundStyle(Theme.inkDim))
                                    .font(.system(size: 14.5))
                                    .foregroundStyle(Theme.ink)
                                    .keyboardType(.URL)
                                    .textContentType(.URL)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .tint(Theme.primary)
                                    .onChange(of: urlText) { _, newValue in
                                        if title.isEmpty && !newValue.isEmpty {
                                            fetchTitle()
                                        }
                                    }

                                if !urlText.isEmpty {
                                    Button {
                                        urlText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Theme.inkDim)
                                    }
                                }
                            }
                            .padding(14)
                            .background(urlText.isEmpty ? Theme.surface : Theme.surfaceHi)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(urlText.isEmpty ? Theme.border : Theme.primary.opacity(0.4), lineWidth: 1)
                            )

                            Text("YouTube, Pinterest, Instagram, TikTok of een andere website")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.inkDim)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TITEL")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundStyle(Theme.inkDim)
                                .tracking(1)

                            TextField("", text: $title, prompt: Text("Naam voor dit idee").foregroundStyle(Theme.inkDim))
                                .font(.system(size: 14.5))
                                .foregroundStyle(Theme.ink)
                                .tint(Theme.primary)
                                .padding(14)
                                .background(Theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Theme.border, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)

                        // Loading indicator
                        if isLoading {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .tint(Theme.primarySoft)
                                Text("Link info ophalen...")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.inkMute)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Theme.border, lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }

                        // Platform detection hint
                        if !urlText.isEmpty {
                            let platform = detectPlatformSync(from: urlText)
                            if platform != "Web" {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Theme.platformColor(for: platform))
                                        .frame(width: 10, height: 10)
                                    Text("\(platform) link herkend")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Theme.inkMute)
                                }
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Link toevoegen")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Annuleer")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.inkMute)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveItem()
                    } label: {
                        Text("Bewaar")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(canSave ? Theme.primary : Theme.inkDim)
                    }
                    .disabled(!canSave)
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
        let itemTitle = title.isEmpty ? "Knutselidee" : title

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
        .preferredColorScheme(.dark)
}
