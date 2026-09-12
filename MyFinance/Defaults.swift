import Foundation

enum Defaults {

    static let categories: [Category] = [
        Category(name: "Продукты",    kind: .expense, emoji: "🛒", limit: 20000),
        Category(name: "Кафе",        kind: .expense, emoji: "☕️", limit: 8000),
        Category(name: "Транспорт",   kind: .expense, emoji: "🚌", limit: 5000),
        Category(name: "Жильё",       kind: .expense, emoji: "🏠", limit: 40000),
        Category(name: "Развлечения", kind: .expense, emoji: "🎬", limit: 6000),
        Category(name: "Здоровье",    kind: .expense, emoji: "💊", limit: nil),
        Category(name: "Зарплата",    kind: .income,  emoji: "💼", limit: nil),
        Category(name: "Подработка",  kind: .income,  emoji: "💸", limit: nil)
    ]

    static let goals: [Goal] = [
        Goal(name: "Подушка безопасности", emoji: "🛟", target: 150000, saved: 30000),
        Goal(name: "Отпуск",               emoji: "✈️", target: 80000,  saved: 12000)
    ]

    static let settings = Settings(startingBalance: 25000, theme: .system)
}
