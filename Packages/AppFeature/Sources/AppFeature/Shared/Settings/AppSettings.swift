import Foundation

public enum AppearanceMode: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public var id: Self { self }

    public var title: LocalizedStringResource {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case german = "de"

    public var id: Self { self }

    public var title: LocalizedStringResource {
        switch self {
        case .english: "English"
        case .german: "German"
        }
    }

    public var locale: Locale {
        Locale(identifier: rawValue)
    }
}
