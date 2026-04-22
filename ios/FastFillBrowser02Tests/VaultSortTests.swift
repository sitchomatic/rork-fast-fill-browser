//
//  VaultSortTests.swift
//  FastFillBrowser02Tests
//
//  Tests for VaultViewModel sort-ordering of credentials and for the
//  excluded-domain helpers that the vault relies on to hide entries.
//

import Testing
import Foundation
@testable import FastFillBrowser02

struct VaultSortTests {

    @MainActor
    private func makeCredential(
        domain: String,
        username: String,
        usageCount: Int = 0,
        lastUsedAt: Date? = nil,
        createdAt: Date = Date()
    ) -> Credential {
        let c = Credential(domain: domain, username: username)
        c.usageCount = usageCount
        c.lastUsedAt = lastUsedAt
        c.createdAt = createdAt
        return c
    }

    @Test @MainActor
    func sortByDomain_ordersByDomainThenUsername() {
        let creds = [
            makeCredential(domain: "b.com", username: "zack"),
            makeCredential(domain: "a.com", username: "bob"),
            makeCredential(domain: "a.com", username: "alice"),
        ]
        let sorted = VaultViewModel.sortCredentials(creds, by: .domain)
        #expect(sorted.map(\.username) == ["alice", "bob", "zack"])
    }

    @Test @MainActor
    func sortByRecentlyUsed_putsMostRecentFirstAndNilsLast() {
        let now = Date()
        let creds = [
            makeCredential(domain: "a.com", username: "never"),
            makeCredential(domain: "a.com", username: "old",    lastUsedAt: now.addingTimeInterval(-1000)),
            makeCredential(domain: "a.com", username: "recent", lastUsedAt: now),
        ]
        let sorted = VaultViewModel.sortCredentials(creds, by: .recentlyUsed)
        #expect(sorted.map(\.username) == ["recent", "old", "never"])
    }

    @Test @MainActor
    func sortByMostUsed_descendingUsageCount() {
        let creds = [
            makeCredential(domain: "a.com", username: "one",  usageCount: 1),
            makeCredential(domain: "a.com", username: "ten",  usageCount: 10),
            makeCredential(domain: "a.com", username: "five", usageCount: 5),
        ]
        let sorted = VaultViewModel.sortCredentials(creds, by: .mostUsed)
        #expect(sorted.map(\.username) == ["ten", "five", "one"])
    }

    @Test @MainActor
    func sortByRecentlyAdded_descendingCreatedAt() {
        let now = Date()
        let creds = [
            makeCredential(domain: "a.com", username: "oldest",   createdAt: now.addingTimeInterval(-2000)),
            makeCredential(domain: "a.com", username: "newest",   createdAt: now),
            makeCredential(domain: "a.com", username: "middle",   createdAt: now.addingTimeInterval(-1000)),
        ]
        let sorted = VaultViewModel.sortCredentials(creds, by: .recentlyAdded)
        #expect(sorted.map(\.username) == ["newest", "middle", "oldest"])
    }

    @Test @MainActor
    func excludedDomain_lowercasesOnInit() {
        let ex = ExcludedDomain(domain: "Example.COM")
        #expect(ex.domain == "example.com")
        #expect(ex.displayDomain == "example.com")
    }

    @Test @MainActor
    func excludedDomain_displayStripsWwwPrefix() {
        let ex = ExcludedDomain(domain: "www.example.com")
        #expect(ex.displayDomain == "example.com")
    }

    @Test @MainActor
    func excludedDomain_displayOnlyStripsLeadingWww() {
        // "awww.example.com" must NOT be mangled — only a leading "www." prefix is stripped.
        let ex = ExcludedDomain(domain: "awww.example.com")
        #expect(ex.displayDomain == "awww.example.com")
    }
}
