import SwiftUI
import SwiftData
import PhotosUI

struct EditCollectionSheet: View {
    @Bindable var collection: CraftCollection
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var thumbnailImage: UIImage?

    init(collection: CraftCollection) {
        self.collection = collection
        _name = State(initialValue: collection.name)
        _selectedIcon = State(initialValue: collection.icon)
        _selectedColor = State(initialValue: collection.colorName)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Preview card
                            ZStack {
                                if let thumbnailImage {
                                    Image(uiImage: thumbnailImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else if let thumbnailURL = collection.thumbnailURL,
                                          let data = try? Data(contentsOf: thumbnailURL),
                                          let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
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
                                        .frame(height: 120)

                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 36))
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                            .padding(.top)

                            Text(name.isEmpty ? L.nameCollection : name)
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? Theme.textTertiary : .white)

                            // Thumbnail picker
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                HStack(spacing: 8) {
                                    Image(systemName: thumbnailImage == nil ? "photo.badge.plus" : "photo.fill")
                                    Text(thumbnailImage == nil ? L.chooseThumbnail : L.changeThumbnail)
                                }
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Theme.surface2)
                                .foregroundStyle(Theme.primaryColor)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Theme.borderColor, lineWidth: 1)
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
                                Text(L.nameLabel)
                                    .font(.caption.bold())
                                    .foregroundStyle(Theme.textSecondary)
                                TextField(L.collectionNamePlaceholder, text: $name)
                                    .padding(12)
                                    .background(Theme.surface2)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Theme.borderColor, lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal)

                            // Icon picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L.chooseIcon)
                                    .font(.caption.bold())
                                    .foregroundStyle(Theme.textSecondary)
                                    .padding(.horizontal)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                    ForEach(CraftCollection.availableIcons, id: \.self) { icon in
                                        Button {
                                            selectedIcon = icon
                                        } label: {
                                            Image(systemName: icon)
                                                .font(.title3)
                                                .frame(width: 50, height: 50)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(selectedIcon == icon
                                                              ? Theme.color(for: selectedColor).opacity(0.2)
                                                              : Theme.surface2)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(selectedIcon == icon ? Theme.color(for: selectedColor) : Theme.borderColor, lineWidth: selectedIcon == icon ? 2 : 1)
                                                )
                                                .foregroundStyle(selectedIcon == icon
                                                                 ? Theme.color(for: selectedColor)
                                                                 : Theme.textSecondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Color picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L.chooseColor)
                                    .font(.caption.bold())
                                    .foregroundStyle(Theme.textSecondary)
                                    .padding(.horizontal)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
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
                                                        .font(.headline.bold())
                                                        .foregroundStyle(.white)
                                                        .opacity(selectedColor == color ? 1 : 0)
                                                )
                                                .shadow(color: selectedColor == color ? Theme.color(for: color).opacity(0.5) : .clear, radius: 4)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Spacer(minLength: 80)
                        }
                    }

                    // Fixed bottom button
                    VStack {
                        Button {
                            saveChanges()
                        } label: {
                            Text(L.saveChanges)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(canSave ? Theme.accentGradient : LinearGradient(colors: [Theme.surface3, Theme.surface3], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(canSave ? .white : Theme.textTertiary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!canSave)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .padding(.top, 8)
                    .background(Theme.bg)
                }
            }
            .navigationTitle(L.editCollection)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L.cancel) { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private func saveChanges() {
        if let thumbnailImage, let data = thumbnailImage.jpegData(compressionQuality: 0.8) {
            let fileName = "\(UUID().uuidString).jpg"
            let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imageDir = docsURL.appendingPathComponent("CollectionThumbnails", isDirectory: true)
            try? FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
            let fileURL = imageDir.appendingPathComponent(fileName)
            try? data.write(to: fileURL)
            collection.thumbnailImagePath = fileURL.absoluteString
        }

        collection.name = name.trimmingCharacters(in: .whitespaces)
        collection.icon = selectedIcon
        collection.colorName = selectedColor
        try? modelContext.save()
        dismiss()
    }
}
