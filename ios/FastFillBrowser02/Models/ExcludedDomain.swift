import SwiftData
import Foundation

/// A domain for which the browser should never auto-fill credentials or
/// offer to save new credentials. Used to "move" credentials out of the
/// active vault without losing the intent to skip that site in the future.
@Model
class ExcludedDomain {
    #Index<ExcludedDomain>([\.domain])

    @Attribute(.unique) var domain: String
    var createdAt: Date

    init(domain: String) {
        self.domain = domain.lowercased()
        self.createdAt = Date()
    }

    var displayDomain: String {
        domain.replacingOccurrences(of: "www.", with: "")
    }
}
