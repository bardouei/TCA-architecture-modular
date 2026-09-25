import DesignSystem
import SwiftUI

public enum AppearanceMode: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public var id: Self { self }

    public var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

struct ModuleShowcaseView: View {
    @State private var model = ModuleShowcaseModel()
    @AppStorage("appearance.mode") private var appearanceRawValue = AppearanceMode.system.rawValue

    var body: some View {
        NavigationStack {
            ScrollView {
                DSContainer {
                    LazyVStack(spacing: DSSpacing.lg) {
                        appearanceSection
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
                    subtitle: "System، Light و Dark به‌صورت زنده",
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

    private var designSystemSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSSectionHeader(
                    "DesignSystem",
                    subtitle: "Tokenها، Card، Button، Badge، Loading و Empty State",
                    systemImage: "paintpalette"
                )
                Text("Large title")
                    .font(DSTypography.largeTitle)
                    .foregroundStyle(DSColor.textPrimary)
                Text("متن semantic و سازگار با Dynamic Type")
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
                    description: "نمونهٔ وضعیت خالی مشترک در Featureها"
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
                    subtitle: "تمام عملیات با async/await اجرا می‌شوند",
                    systemImage: "network"
                )
                demoStatus(model.networkState)
                demoButton("درخواست تکی", image: "1.circle") { await model.runSingleRequest() }
                demoButton("درخواست هم‌زمان", image: "arrow.triangle.branch") { await model.runConcurrentRequests() }
                demoButton("درخواست پشت‌سرهم", image: "list.number") { await model.runSequentialRequests() }
                demoButton("صف اولویت‌دار", image: "list.bullet.rectangle") { await model.runPriorityQueue() }
                demoButton("Network Cache", image: "memorychip") { await model.runNetworkCache() }
                demoButton("دانلود یک تصویر", image: "arrow.down.circle") { await model.downloadSingleImage() }
                demoButton("دانلود چند تصویر", image: "square.stack.3d.down.right") { await model.downloadMultipleImages() }
                demoButton("آپلود فایل", image: "arrow.up.circle") { await model.runUpload() }

                if !model.downloadedImageURLs.isEmpty {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("فایل‌های دانلودشده")
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
                    subtitle: "Preferences، DiskCache، Keychain، Core Data و Facade",
                    systemImage: "externaldrive"
                )
                demoStatus(model.storageState)
                demoButton("UserDefaults و DiskCache", image: "internaldrive") {
                    await model.runPreferencesAndDiskCache()
                }
                demoButton("Keychain کامل", image: "key") {
                    await model.runKeychain()
                }
                demoButton("Core Data و StorageFacade", image: "cylinder") {
                    await model.runCoreData()
                }
            }
        }
    }

    private func demoButton(
        _ title: String,
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
            DSBadge("آمادهٔ اجرا")
        case .running:
            HStack(spacing: DSSpacing.sm) {
                ProgressView()
                Text("در حال اجرا…")
                    .font(DSTypography.callout)
            }
        case let .success(message):
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSBadge("موفق", kind: .success)
                Text(message)
                    .font(DSTypography.footnote)
                    .foregroundStyle(DSColor.textSecondary)
            }
        case let .failure(message):
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                DSBadge("خطا", kind: .error)
                Text(message)
                    .font(DSTypography.footnote)
                    .foregroundStyle(DSColor.error)
            }
        }
    }
}
