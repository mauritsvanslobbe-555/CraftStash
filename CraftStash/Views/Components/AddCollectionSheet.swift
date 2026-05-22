import SwiftUI
import SwiftData
import PhotosUI

struct AddCollectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = "coral"
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var thumbnailImage: UIImage?

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Preview card
                            ZStack {
                                if let thumbnailImage {
                                    Image(uiImage: thumbnailImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 130)
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                } else {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Theme.color(for: selectedColor).opacity(0.8),
                                                    Theme.color(for: selectedColor).opacity(0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(height: 130)

                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 36))
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .frame(height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                            Text(name.isEmpty ? "Naam collectie" : name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(name.isEmpty ? Theme.inkDim : Theme.ink)

                            // Thumbnail picker
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                HStack(spacing: 8) {
                                    Image(systemName: thumbnailImage == nil ? "photo.badge.plus" : "photo.fill")
                                        .font(.system(size: 13))
                                    Text(thumbnailImage == nil ? "Kies een thumbnail" : "Thumbnail wijzigen")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundStyle(Theme.primarySoft)
                                .padding(.horizontal, 16)
                                .frame(height: 38)
                                .background(Theme.surfaceHi)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Theme.border, lineWidth: 1)
                                )
                            }
                            .onChange(of: selectedPhoto) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        thumbnailImage = uiImage
                                    }
                                }
                            }

                            // Name field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NAAM")
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundStyle(Theme.inkDim)
                                    .tracking(1)

                                TextField("", text: $name, prompt: Text("Bijv. Kerstknutsels").foregroundStyle(Theme.inkDim))
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

                            // Icon picker
                            VStack(alignment: .leading, spacing: 10) {
                                Text("ICOON")
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundStyle(Theme.inkDim)
                                    .tracking(1)
                                    .padding(.horizontal, 20)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                                    ForEach(CraftCollection.availableIcons, id: \.self) { icon in
                                        Button {
                                            selectedIcon = icon
                                        } label: {
                                            Image(systemName: icon)
                                                .font(.system(size: 18))
                                                .frame(width: 50, height: 50)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .fill(selectedIcon == icon
                                                              ? Theme.color(for: selectedColor).opacity(0.2)
                                                              : Theme.surface)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(selectedIcon == icon ? Theme.color(for: selectedColor) : Theme.border, lineWidth: selectedIcon == icon ? 2 : 1)
                                                )
                                                .foregroundStyle(selectedIcon == icon
                                                                 ? Theme.color(for: selectedColor)
                                                                 : Theme.inkMute)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            // Color picker
                            VStack(alignment: .leading, spacing: 10) {
                                Text("KLEUR")
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundStyle(Theme.inkDim)
                                    .tracking(1)
                                    .padding(.horizontal, 20)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                                    ForEach(CraftCollection.availableColors, id: \.self) { color in
                                        Button {
                                            selectedColor = color
                                        } label: {
                                            Circle()
                                                .fill(Theme.color(for: color))
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Circle()
                                                        .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                                )
                                                .overlay(
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundStyle(.white)
                                                        .opacity(selectedColor == color ? 1 : 0)
                                                )
                                                .shadow(color: selectedColor == color ? Theme.color(for: color).opacity(0.5) : .clear, radius: 6)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            Spacer(minLength: 80)
                        }
                    }

                    // Fixed bottom button
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)

                        Button {
                            createCollection()
                        } label: {
                            Text("Maak aan")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(canSave ? Theme.primary : Theme.surfaceHi)
                                .foregroundStyle(canSave ? .white : Theme.inkDim)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: canSave ? Theme.primary.opacity(0.4) : .clear, radius: 12, y: 4)
                        }
                        .disabled(!canSave)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .background(Theme.bg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Nieuwe collectie")
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
            }
        }
    }

    private func createCollection() {
        var savedImagePath: String?

        if let thumbnailImage, let data = thumbnailImage.jpegData(compressionQuality: 0.8) {
            let fileName = "\(UUID().uuidString).jpg"
            let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imageDir = docsURL.appendingPathComponent("CollectionThumbnails", isDirectory: true)
            try? FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
            let fileURL = imageDir.appendingPathComponent(fileName)
            try? data.write(to: fileURL)
            // Store relative path so it survives app container UUID changes
            savedImagePath = "CollectionThumbnails/\(fileName)"
        }

        let collection = CraftCollection(
            name: name.trimmingCharacters(in: .whitespaces),
            icon: selectedIcon,
            colorName: selectedColor,
            thumbnailImagePath: savedImagePath
        )
        modelContext.insert(collection)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddCollectionSheet()
        .modelContainer(for: [CraftItem.self, CraftCollection.self], inMemory: true)
        .preferredColorScheme(.dark)
}
