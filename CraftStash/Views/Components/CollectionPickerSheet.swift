import SwiftUI
import SwiftData

struct CollectionPickerSheet: View {
    let item: CraftItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CraftCollection.name) private var collections: [CraftCollection]
    @State private var showingNewCollection = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if collections.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.primarySoft)

                        Text("Geen collecties")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.ink)

                        Text("Maak eerst een collectie aan")
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.inkMute)

                        Button {
                            showingNewCollection = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Nieuwe collectie")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .frame(height: 42)
                            .background(Theme.primary)
                            .clipShape(Capsule())
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(collections) { collection in
                                Button {
                                    toggleCollection(collection)
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Theme.color(for: collection.colorName))
                                                .frame(width: 38, height: 38)
                                            Image(systemName: collection.icon)
                                                .font(.system(size: 14))
                                                .foregroundStyle(.white)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(collection.name)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(Theme.ink)
                                            Text("\(collection.itemCount) items")
                                                .font(.system(size: 12))
                                                .foregroundStyle(Theme.inkDim)
                                        }

                                        Spacer()

                                        if isInCollection(collection) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundStyle(Theme.color(for: collection.colorName))
                                        } else {
                                            Circle()
                                                .stroke(Theme.border, lineWidth: 1.5)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                }
                                .buttonStyle(.plain)

                                if collection.id != collections.last?.id {
                                    Rectangle()
                                        .fill(Theme.border)
                                        .frame(height: 1)
                                        .padding(.leading, 70)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Toevoegen aan collectie")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Klaar")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.inkMute)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewCollection = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.primarySoft)
                    }
                }
            }
            .sheet(isPresented: $showingNewCollection) {
                AddCollectionSheet()
            }
        }
    }

    private func isInCollection(_ collection: CraftCollection) -> Bool {
        collection.items?.contains(where: { $0.id == item.id }) ?? false
    }

    private func toggleCollection(_ collection: CraftCollection) {
        if isInCollection(collection) {
            collection.items?.removeAll(where: { $0.id == item.id })
        } else {
            if collection.items == nil {
                collection.items = []
            }
            collection.items?.append(item)
        }
        try? modelContext.save()
    }
}
