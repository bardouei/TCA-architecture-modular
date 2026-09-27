import DesignSystem
import SwiftUI

struct ModuleShowcaseView: View {
    @State private var model = ModuleShowcaseModel()
    @AppStorage("appearance.mode") private var appearanceRawValue = AppearanceMode.system.rawValue
    @AppStorage("app.language") private var languageRawValue = AppLanguage.english.rawValue

    var body: some View {
        NavigationStack {
            ScrollView {
                DSContainer {
                    LazyVStack(spacing: DSSpacing.lg) {
                        appearanceSection
                        languageSection
                        designSystemSection
                        networkSection
                        storageSection
                    }
                }
            }
            .background(DSColor.background)
            .navigationTitle("Module Showcase")
        }
    }

    private var appearanceSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSSectionHeader(
                    "Appearance",
                    subtitle: "Switch between system, light, and dark appearance live.",
                    systemImage: "circle.lefthalf.filled"
                )
                Picker("Appearance", selection: $appearanceRawValue) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var languageSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSSectionHeader(
                    "Language",
                    subtitle: "Choose English or German.",
                    systemImage: "globe"
                )
                Picker("Language", selection: $languageRawValue) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.title).tag(language.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var designSystemSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSSectionHeader(
                    "DesignSystem",
                    subtitle: "Tokens, cards, buttons, badges, loading, and empty states.",
                    systemImage: "paintpalette"
                )
                Text("Large title")
                    .font(DSTypography.largeTitle)
                    .foregroundStyle(DSColor.textPrimary)
                Text("Semantic text that supports Dynamic Type")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColor.textSecondary)
                ViewThatFits(in: .horizontal) {
                    HStack {
                        statusBadges
                    }
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        statusBadges
                    }
                }
                DSButton("Primary Button", systemImage: "checkmark") {}
                DSButton("Secondary Button", style: .secondary) {}
                DSButton("Destructive Button", systemImage: "trash", style: .destructive) {}
                DSLoadingView()
                DSEmptyStateView(
                    title: "Empty State",
                    description: "A shared empty-state example for features."
                )
            }
        }
    }

    @ViewBuilder
    private var statusBadges: some View {
        DSBadge("Info")
        DSBadge("Success", kind: .success)
        DSBadge("Warning", kind: .warning)
        DSBadge("Error", kind: .error)
    }

    private var networkSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSSectionHeader(
                    "NetworkCore",
                    subtitle: "All operations run with async/await.",
                    systemImage: "network"
                )
                demoStatus(model.networkState)
                demoButton("Single request", image: "1.circle") { await model.runSingleRequest() }
                demoButton("Concurrent requests", image: "arrow.triangle.branch") { await model.runConcurrentRequests() }
                demoButton("Sequential requests", image: "list.number") { await model.runSequentialRequests() }
                demoButton("Priority queue", image: "list.bullet.rectangle") { await model.runPriorityQueue() }
                demoButton("Network Cache", image: "memorychip") { await model.runNetworkCache() }
                demoButton("Download one image", image: "arrow.down.circle") { await model.downloadSingleImage() }
                demoButton("Download multiple images", image: "square.stack.3d.down.right") { await model.downloadMultipleImages() }
                demoButton("Upload file", image: "arrow.up.circle") { await model.runUpload() }

                if !model.downloadedImageURLs.isEmpty {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Downloaded files")
                            .font(DSTypography.headline)
                        ForEach(model.downloadedImageURLs, id: \.self) { url in
                            Label(url.lastPathComponent, systemImage: "photo")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColor.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private var storageSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSSectionHeader(
                    "StorageCore",
                    subtitle: "Preferences, DiskCache, Keychain, Core Data, and Facade.",
                    systemImage: "externaldrive"
                )
                demoStatus(model.storageState)
                demoButton("UserDefaults and DiskCache", image: "internaldrive") {
                    await model.runPreferencesAndDiskCache()
                }
                demoButton("Complete Keychain flow", image: "key") {
                    await model.runKeychain()
                }
                demoButton("Core Data and StorageFacade", image: "cylinder") {
                    await model.runCoreData()
                }
            }
        }
    }

    private func demoButton(
        _ title: LocalizedStringResource,
        image: String,
        operation: @escaping @MainActor () async -> Void
    ) -> some View {
        DSButton(title, systemImage: image, style: .secondary) {
            Task { await operation() }
        }
    }

    @ViewBuilder
    private func demoStatus(_ state: ModuleShowcaseModel.DemoState) -> some View {
        switch state {
        case .idle:
            DSBadge("Ready to run")
        case .running:
            HStack(spacing: DSSpacing.sm) {
                ProgressView()
                Text("Running…")
                    .font(DSTypography.callout)
            }
        case let .success(message):
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSBadge("Success", kind: .success)
                Text(message)
                    .font(DSTypography.footnote)
                    .foregroundStyle(DSColor.textSecondary)
            }
        case let .failure(message):
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSBadge("Error", kind: .error)
                Text(message)
                    .font(DSTypography.footnote)
                    .foregroundStyle(DSColor.error)
            }
        }
    }
}
