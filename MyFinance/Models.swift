import Foundation

enum TxKind: String, Codable, CaseIterable {
    case expense
    case income

    var title: String {
        switch self {
        case .expense: return "Расход"
        case .income: return "Доход"
        }
    }
}

struct Category: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var kind: TxKind
    var emoji: String
    var limit: Double?
}

struct Transaction: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var amount: Double
    var kind: TxKind
    var categoryId: String
    var note: String = ""
    var date: Date = Date()
}

struct Goal: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var emoji: String
    var target: Double
    var saved: Double = 0
}

enum ThemeChoice: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Тёмная"
        }
    }
}

struct Settings: Codable {
    var startingBalance: Double = 0
    var theme: ThemeChoice = .system
}
