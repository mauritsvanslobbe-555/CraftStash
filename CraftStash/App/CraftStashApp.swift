import SwiftUI
import SwiftData

@main
struct CraftStashApp: App {
    let modelContainer: ModelContainer
    @State private var languageManager = LanguageManager.shared

    init() {
        let schema = Schema([CraftItem.self, CraftCollection.self])
        let config = ModelConfiguration(
            "CraftStash",
            schema: schema,
            groupContainer: .identifier("group.com.craftstash.shared")
        )
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageManager)
        }
        .modelContainer(modelContainer)
    }
}
