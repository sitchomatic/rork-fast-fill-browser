import SwiftUI
import SwiftData

struct ExcludedDomainsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExcludedDomain.domain) private var excluded: [ExcludedDomain]

    @State private var newDomain: String = ""

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("example.com", text: $newDomain)
                        .font(.callout.monospaced())
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .onSubmit(addDomain)

                    Button("Add", action: addDomain)
                        .buttonStyle(.borderedProminent)
                        .disabled(trimmedDomain.isEmpty)
                }
            } header: {
                Text("Add Domain")
            } footer: {
                Text("Excluded domains are skipped for auto-fill and save prompts. Credentials saved for them stay hidden from the active vault.")
            }

            if !excluded.isEmpty {
                Section("Excluded (\(excluded.count))") {
                    ForEach(excluded) { item in
                        HStack {
                            Image(systemName: "nosign")
                                .foregroundStyle(.orange)
                            Text(item.displayDomain)
                                .font(.body)
                            Spacer()
                            Text(item.createdAt, format: .relative(presentation: .named))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Remove", role: .destructive) {
                                modelContext.delete(item)
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            if excluded.isEmpty {
                ContentUnavailableView(
                    "No Excluded Domains",
                    systemImage: "nosign",
                    description: Text("Add a domain above to skip auto-fill and save prompts for it.")
                )
            }
        }
        .navigationTitle("Excluded Domains")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { dismiss() }
            }
        }
    }

    private var trimmedDomain: String {
        ExcludedDomain.canonicalize(newDomain)
    }

    private func addDomain() {
        let domain = trimmedDomain
        guard !domain.isEmpty else { return }
        let descriptor = FetchDescriptor<ExcludedDomain>(
            predicate: #Predicate<ExcludedDomain> { $0.domain == domain }
        )
        if (try? modelContext.fetch(descriptor).first) == nil {
            modelContext.insert(ExcludedDomain(domain: domain))
        }
        newDomain = ""
    }
}
