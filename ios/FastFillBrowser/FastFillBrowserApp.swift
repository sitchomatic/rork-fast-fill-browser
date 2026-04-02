import SwiftUI
import SwiftData

@main
struct FastFillBrowserApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Credential.self,
            SiteSetting.self,
            BrowsingHistoryEntry.self,
            Bookmark.self
        ])
    }
}
