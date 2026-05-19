import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    @Bindable var collection: CraftCollection
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: CraftItem?
    @State private var showingAddItems = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            if let items = collection.items, !items.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerView

                        // Stats
                        Text("\(collection.items?.count ?? 0) items")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.inkMute)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)

                        MasonryGrid(items: items.sorted(by: { $0.dateAdded > $1.dateAdded })) { item in
                            selectedItem = item
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 8)
                }
            } else {
                VStack(spacing: 0) {
                    headerView
                        .padding(.bottom, 0)

                    Spacer()

                    VStack(spacing: 14) {
                        Image(systemName: collection.icon)
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.color(for: collection.colorName))

                        Text("Collectie is leeg")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.ink)

                        Text("Voeg knutselideeën toe aan deze collectie")
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.inkMute)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)

                        Button {
                            showingAddItems = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Ideeën toevoegen")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .frame(height: 46)
                            .background(Theme.primary)
                            .clipShape(Capsule())
                            .shadow(color: Theme.primary.opacity(0.4), radius: 12, y: 4)
                        }
                        .padding(.top, 4)
                    }
                    .padding()

                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedItem) { item in
            CraftItemDetailView(item: item)
        }
        .sheet(isPresented: $showingAddItems) {
            AddItemsToCollectionSheet(collection: collection)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            // Back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 36, height: 36)
                    .background(Theme.surface)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Theme.border, lineWidth: 1)
                    )
            }

            // Collection icon + name
            ZStack {
                Circle()
                    .fill(Theme.color(for: collection.colorName))
                    .frame(width: 32, height: 32)
                Image(systemName: collection.icon)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("COLLECTIE")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.inkDim)
                    .tracking(1)
                Text(collection.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
            }

            Spacer()

            // Add button
            Button {
                showingAddItems = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.primarySoft)
                    .frame(width: 36, height: 36)
                    .background(Theme.primaryTint)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Theme.primary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}
