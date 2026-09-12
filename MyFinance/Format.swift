import Foundation

enum Format {

    private static let money: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "RUB"
        f.currencySymbol = "₽"
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "ru_RU")
        return f
    }()

    static func amount(_ value: Double) -> String {
        money.string(from: NSNumber(value: value)) ?? "\(Int(value)) ₽"
    }

    static func signed(_ value: Double, kind: TxKind) -> String {
        let sign = kind == .income ? "+" : "−"
        return sign + amount(abs(value))
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM"
        return f
    }()

    static func day(_ date: Date) -> String {
        dayFormatter.string(from: date)
    }

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "LLLL yyyy"
        return f
    }()

    static func month(_ date: Date) -> String {
        monthFormatter.string(from: date).capitalized
    }

    static func shortMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "LLL"
        return f.string(from: date)
    }
}
