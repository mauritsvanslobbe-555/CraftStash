import SwiftUI

enum AppLanguage: String, CaseIterable {
    case nl = "nl"
    case en = "en"

    var displayName: String {
        switch self {
        case .nl: return "Nederlands"
        case .en: return "English"
        }
    }

    var flag: String {
        switch self {
        case .nl: return "🇳🇱"
        case .en: return "🇬🇧"
        }
    }
}

@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    var current: AppLanguage {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "appLanguage")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "nl"
        self.current = AppLanguage(rawValue: saved) ?? .nl
    }
}

// MARK: - Localized Strings
enum L {
    private static var lang: AppLanguage { LanguageManager.shared.current }

    // App
    static var appName: String { "StuffStash" }

    // Tabs
    static var tabHome: String { "Home" }
    static var tabCollections: String { lang == .nl ? "Collecties" : "Collections" }
    static var tabSearch: String { lang == .nl ? "Zoeken" : "Search" }
    static var tabFavorites: String { lang == .nl ? "Favorieten" : "Favorites" }
    static var tabHelp: String { "Help" }

    // Home - Slogan
    static var sloganTitle: String { lang == .nl ? "Bewaar alles. Vind alles terug." : "Save everything. Find it all." }
    static var sloganSubtitle: String { lang == .nl ? "Jouw persoonlijke bibliotheek voor al je ideeën." : "Your personal library for all your ideas." }

    // Home - Content
    static var itemsCount: String { lang == .nl ? "items opgeslagen" : "items saved" }
    static var searchPlaceholder: String { lang == .nl ? "Zoek in je stash..." : "Search your stash..." }

    // Home - Filters
    static var filterAll: String { lang == .nl ? "Alles" : "All" }
    static var filterVideos: String { lang == .nl ? "Video's" : "Videos" }
    static var filterPhotos: String { lang == .nl ? "Foto's" : "Photos" }

    // Home - Welcome Banner
    static var tipTitle: String { lang == .nl ? "Tip: Zo bewaar je ideeën" : "Tip: How to save ideas" }
    static var tipDesc: String { lang == .nl ? "Zie je iets leuks? Tik op de deel-knop en kies StuffStash!" : "See something you like? Tap the share button and choose StuffStash!" }

    // Onboarding
    static var welcomeTitle: String { lang == .nl ? "Welkom bij StuffStash!" : "Welcome to StuffStash!" }
    static var welcomeSubtitle: String { lang == .nl ? "Bewaar al je ideeën\nop één plek." : "Save all your ideas\nin one place." }
    static var howItWorks: String { lang == .nl ? "ZO WERKT HET" : "HOW IT WORKS" }
    static var onboardStep1Title: String { lang == .nl ? "Zie iets leuks" : "See something cool" }
    static var onboardStep1Desc: String { lang == .nl ? "Op YouTube, Instagram, TikTok, Pinterest of waar dan ook." : "On YouTube, Instagram, TikTok, Pinterest or anywhere else." }
    static var onboardStep2Title: String { lang == .nl ? "Tik op de deel-knop" : "Tap the share button" }
    static var onboardStep2Desc: String { lang == .nl ? "Kies 'StuffStash' in het deelmenu. Je kunt ook screenshots of foto's delen!" : "Choose 'StuffStash' in the share menu. You can also share screenshots or photos!" }
    static var onboardStep3Title: String { lang == .nl ? "Opgeslagen!" : "Saved!" }
    static var onboardStep3Desc: String { lang == .nl ? "Je idee staat veilig in StuffStash. Organiseer het in mappen en bekijk het wanneer je wilt." : "Your idea is safely stored in StuffStash. Organize it in folders and view it whenever you want." }
    static var worksWithTitle: String { lang == .nl ? "WERKT MET" : "WORKS WITH" }
    static var worksWithFooter: String { lang == .nl ? "En alle andere apps met een deel-knop!" : "And all other apps with a share button!" }

    // Buttons
    static var addLink: String { lang == .nl ? "Link toevoegen" : "Add link" }
    static var saveScreenshot: String { lang == .nl ? "Screenshot opslaan" : "Save screenshot" }
    static var save: String { lang == .nl ? "Bewaar" : "Save" }
    static var cancel: String { lang == .nl ? "Annuleer" : "Cancel" }
    static var done: String { lang == .nl ? "Klaar" : "Done" }
    static var delete: String { lang == .nl ? "Verwijderen" : "Delete" }
    static var edit: String { lang == .nl ? "Bewerk" : "Edit" }
    static var newItem: String { lang == .nl ? "Nieuw" : "New" }

    // Collections
    static var collectionsTitle: String { lang == .nl ? "Collecties" : "Collections" }
    static var newCollection: String { lang == .nl ? "Nieuwe collectie" : "New collection" }
    static var editCollection: String { lang == .nl ? "Collectie bewerken" : "Edit collection" }
    static var createFirstCollection: String { lang == .nl ? "Maak je eerste collectie!" : "Create your first collection!" }
    static var organizeIdeas: String { lang == .nl ? "Organiseer je ideeën in\ngroepen zoals 'Kerst', 'Verjaardag'\nof 'Makkelijk'" : "Organize your ideas in\ngroups like 'Christmas', 'Birthday'\nor 'Easy'" }
    static var collectionEmpty: String { lang == .nl ? "Collectie is leeg" : "Collection is empty" }
    static var addIdeas: String { lang == .nl ? "Voeg ideeën toe" : "Add ideas" }
    static var addIdeasButton: String { lang == .nl ? "Ideeën toevoegen" : "Add ideas" }
    static var collectionNamePlaceholder: String { lang == .nl ? "Bijv. Kerstknutsels" : "E.g. Christmas crafts" }
    static var chooseIcon: String { lang == .nl ? "Kies een icoon" : "Choose an icon" }
    static var chooseColor: String { lang == .nl ? "Kies een kleur" : "Choose a color" }
    static var chooseThumbnail: String { lang == .nl ? "Kies een thumbnail" : "Choose a thumbnail" }
    static var changeThumbnail: String { lang == .nl ? "Thumbnail wijzigen" : "Change thumbnail" }
    static var createButton: String { lang == .nl ? "Maak aan" : "Create" }
    static var saveChanges: String { lang == .nl ? "Wijzigingen opslaan" : "Save changes" }
    static var nameLabel: String { lang == .nl ? "Naam" : "Name" }
    static var nameCollection: String { lang == .nl ? "Naam collectie" : "Collection name" }
    static var collectionsCount: String { lang == .nl ? "collecties" : "collections" }

    // Item Detail
    static var detail: String { "Detail" }
    static var favorite: String { lang == .nl ? "Favoriet" : "Favorite" }
    static var collection: String { lang == .nl ? "Collectie" : "Collection" }
    static var share: String { lang == .nl ? "Deel" : "Share" }
    static var open: String { "Open" }
    static var notes: String { lang == .nl ? "Notities" : "Notes" }
    static var addNotes: String { lang == .nl ? "Voeg notities toe..." : "Add notes..." }
    static var noNotes: String { lang == .nl ? "Geen notities" : "No notes" }
    static var inCollections: String { lang == .nl ? "In collecties" : "In collections" }
    static var deleteItem: String { lang == .nl ? "Item verwijderen" : "Delete item" }
    static var deleteItemConfirm: String { lang == .nl ? "Weet je zeker dat je dit item wilt verwijderen? Dit kan niet ongedaan worden." : "Are you sure you want to delete this item? This cannot be undone." }

    // Favorites
    static var noFavorites: String { lang == .nl ? "Geen favorieten" : "No favorites" }
    static var markFavorites: String { lang == .nl ? "Markeer ideeën als favoriet\nom ze hier terug te vinden!" : "Mark ideas as favorite\nto find them here!" }

    // Search
    static var searchTitle: String { lang == .nl ? "Zoeken" : "Search" }
    static var popularTags: String { lang == .nl ? "POPULAIRE TAGS" : "POPULAR TAGS" }
    static var platforms: String { lang == .nl ? "PLATFORMEN" : "PLATFORMS" }
    static var results: String { lang == .nl ? "resultaten" : "results" }
    static var noResults: String { lang == .nl ? "Geen resultaten" : "No results" }
    static var tryDifferent: String { lang == .nl ? "Probeer een andere zoekterm" : "Try a different search term" }

    // Add Item
    static var addLinkTitle: String { lang == .nl ? "Link toevoegen" : "Add link" }
    static var pasteLink: String { lang == .nl ? "Plak een link..." : "Paste a link..." }
    static var linkFooter: String { lang == .nl ? "Plak een link van YouTube, Pinterest, Instagram, TikTok of een andere website" : "Paste a link from YouTube, Pinterest, Instagram, TikTok or any other website" }
    static var titleLabel: String { lang == .nl ? "Titel" : "Title" }
    static var titlePlaceholder: String { lang == .nl ? "Naam voor dit idee" : "Name for this idea" }
    static var fetchingInfo: String { lang == .nl ? "Link info ophalen..." : "Fetching link info..." }
    static var defaultItemTitle: String { lang == .nl ? "Idee" : "Idea" }

    // Collection Picker
    static var addToCollection: String { lang == .nl ? "Toevoegen aan collectie" : "Add to collection" }
    static var noCollections: String { lang == .nl ? "Geen collecties" : "No collections" }
    static var createCollectionFirst: String { lang == .nl ? "Maak eerst een collectie aan" : "Create a collection first" }
    static var noIdeas: String { lang == .nl ? "Geen ideeën" : "No ideas" }
    static var shareToStuffStash: String { lang == .nl ? "Deel eerst ideeën naar StuffStash" : "Share ideas to StuffStash first" }

    // Guide
    static var guideTitle: String { lang == .nl ? "Hoe werkt het?" : "How does it work?" }
    static var guideHero: String { lang == .nl ? "StuffStash is jouw persoonlijke bibliotheek voor al je ideeën." : "StuffStash is your personal library for all your ideas." }
    static var inSteps: String { lang == .nl ? "IN 4 STAPPEN" : "IN 4 STEPS" }
    static var guideStep1Title: String { lang == .nl ? "Content opslaan" : "Save content" }
    static var guideStep1Desc: String { lang == .nl ? "Deel een link vanuit Instagram, TikTok, YouTube of een andere app naar StuffStash." : "Share a link from Instagram, TikTok, YouTube or any other app to StuffStash." }
    static var guideStep2Title: String { lang == .nl ? "Organiseer in collecties" : "Organize in collections" }
    static var guideStep2Desc: String { lang == .nl ? "Maak collecties aan voor verschillende thema's en voeg items toe." : "Create collections for different themes and add items." }
    static var guideStep3Title: String { lang == .nl ? "Filter en zoek" : "Filter and search" }
    static var guideStep3Desc: String { lang == .nl ? "Filter op platform, type (video/afbeelding) of zoek op titel." : "Filter by platform, type (video/image) or search by title." }
    static var guideStep4Title: String { lang == .nl ? "Bekijk en deel" : "View and share" }
    static var guideStep4Desc: String { lang == .nl ? "Open opgeslagen content in de app of ga terug naar het origineel." : "Open saved content in the app or go back to the original." }
    static var features: String { "FEATURES" }
    static var featureMultiPlatform: String { "Multi-platform" }
    static var featureMultiPlatformDesc: String { lang == .nl ? "Instagram, TikTok, YouTube, Pinterest en meer" : "Instagram, TikTok, YouTube, Pinterest and more" }
    static var featureFastSave: String { lang == .nl ? "Bliksemsnel opslaan" : "Lightning fast saving" }
    static var featureFastSaveDesc: String { lang == .nl ? "Eén tap via de share sheet, klaar" : "One tap via the share sheet, done" }
    static var featureSmartCollections: String { lang == .nl ? "Slimme collecties" : "Smart collections" }
    static var featureSmartCollectionsDesc: String { lang == .nl ? "Organiseer zoals jij wilt met mappen" : "Organize however you want with folders" }
    static var featurePowerfulSearch: String { lang == .nl ? "Krachtig zoeken" : "Powerful search" }
    static var featurePowerfulSearchDesc: String { lang == .nl ? "Vind alles terug op titel of platform" : "Find everything by title or platform" }
    static var faqTitle: String { lang == .nl ? "VEELGESTELDE VRAGEN" : "FAQ" }

    // FAQ
    static var faq1Q: String { lang == .nl ? "Welke platformen worden ondersteund?" : "Which platforms are supported?" }
    static var faq1A: String { lang == .nl ? "StuffStash werkt met Instagram, TikTok, YouTube, Pinterest, Facebook, X en meer." : "StuffStash works with Instagram, TikTok, YouTube, Pinterest, Facebook, X and more." }
    static var faq2Q: String { lang == .nl ? "Hoe sla ik content op?" : "How do I save content?" }
    static var faq2A: String { lang == .nl ? "Gebruik de 'Delen'-knop in een andere app en kies StuffStash. Je kunt ook screenshots importeren via de + knop." : "Use the 'Share' button in another app and choose StuffStash. You can also import screenshots via the + button." }
    static var faq3Q: String { lang == .nl ? "Kan ik screenshots opslaan?" : "Can I save screenshots?" }
    static var faq3A: String { lang == .nl ? "Ja! Tik op de + knop in het home scherm en kies 'Screenshot opslaan' om foto's uit je bibliotheek te importeren." : "Yes! Tap the + button on the home screen and choose 'Save screenshot' to import photos from your library." }
    static var faq4Q: String { lang == .nl ? "Is er een limiet?" : "Is there a limit?" }
    static var faq4A: String { lang == .nl ? "Nee, je kunt onbeperkt content opslaan. Je opslag is alleen beperkt door de ruimte op je apparaat." : "No, you can save unlimited content. Your storage is only limited by the space on your device." }

    // Settings / Language
    static var language: String { lang == .nl ? "Taal" : "Language" }
    static var settings: String { lang == .nl ? "Instellingen" : "Settings" }

    // Screenshot item title
    static var screenshotTitle: String { lang == .nl ? "Screenshot idee" : "Screenshot idea" }

    // Unknown platform
    static var unknownPlatform: String { lang == .nl ? "Onbekend" : "Unknown" }

    // Items label
    static var items: String { "items" }

    // Delete collection
    static var deleteCollection: String { lang == .nl ? "Collectie verwijderen" : "Delete collection" }
}
