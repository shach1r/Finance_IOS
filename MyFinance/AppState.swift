import Foundation
import SwiftUI
import Combine

final class AppState: ObservableObject {

    @Published var categories: [Category]
    @Published var transactions: [Transaction]
    @Published var goals: [Goal]
    @Published var settings: Settings

    private let store: LocalStore
    private let calendar = Calendar(identifier: .gregorian)

    init(store: LocalStore = LocalStore()) {
        self.store = store
        categories = store.load("categories", as: [Category].self) ?? Defaults.categories
        transactions = store.load("transactions", as: [Transaction].self) ?? []
        goals = store.load("goals", as: [Goal].self) ?? Defaults.goals
        settings = store.load("settings", as: Settings.self) ?? Defaults.settings
    }

    func addTransaction(_ tx: Transaction) {
        transactions.append(tx)
        saveTransactions()
    }

    func deleteTransaction(_ tx: Transaction) {
        transactions.removeAll { $0.id == tx.id }
        saveTransactions()
    }

    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }

    func updateCategory(_ category: Category) {
        guard let i = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[i] = category
        saveCategories()
    }

    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }

    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }

    func topUp(_ goal: Goal, by amount: Double) {
        guard let i = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        var updated = goals[i]
        updated.saved += amount
        goals[i] = updated
        saveGoals()
    }

    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }

    func updateSettings(_ new: Settings) {
        settings = new
        store.save("settings", settings)
    }

    private func saveTransactions() { store.save("transactions", transactions) }
    private func saveCategories() { store.save("categories", categories) }
    private func saveGoals() { store.save("goals", goals) }

    var balance: Double {
        let income = transactions.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
        let expense = transactions.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount }
        return settings.startingBalance + income - expense
    }

    func category(_ id: String) -> Category? {
        categories.first { $0.id == id }
    }

    private func monthStart(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    private func inSameMonth(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, equalTo: b, toGranularity: .month)
    }

    func total(kind: TxKind, month: Date) -> Double {
        transactions
            .filter { $0.kind == kind && inSameMonth($0.date, month) }
            .reduce(0) { $0 + $1.amount }
    }

    func spent(categoryId: String, month: Date) -> Double {
        transactions
            .filter { $0.kind == .expense && $0.categoryId == categoryId && inSameMonth($0.date, month) }
            .reduce(0) { $0 + $1.amount }
    }

    func transactions(inMonth month: Date) -> [Transaction] {
        transactions
            .filter { inSameMonth($0.date, month) }
            .sorted { $0.date > $1.date }
    }

    struct CategoryShare: Identifiable {
        let id: String
        let category: Category
        let amount: Double
        let share: Double
    }

    func expenseReport(month: Date) -> [CategoryShare] {
        let monthExpenses = transactions.filter {
            $0.kind == .expense && inSameMonth($0.date, month)
        }
        let total = monthExpenses.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }

        var byCategory: [String: Double] = [:]
        for tx in monthExpenses {
            byCategory[tx.categoryId, default: 0] += tx.amount
        }

        return byCategory.compactMap { id, amount -> CategoryShare? in
            guard let cat = category(id) else { return nil }
            return CategoryShare(id: id, category: cat, amount: amount, share: amount / total)
        }
        .sorted { $0.amount > $1.amount }
    }

    struct MonthPoint: Identifiable {
        let id: String
        let month: Date
        let income: Double
        let expense: Double
    }

    func lastSixMonths() -> [MonthPoint] {
        let now = Date()
        var points: [MonthPoint] = []
        for offset in stride(from: 5, through: 0, by: -1) {
            guard let m = calendar.date(byAdding: .month, value: -offset, to: now) else { continue }
            let key = Format.month(m)
            points.append(
                MonthPoint(
                    id: key,
                    month: m,
                    income: total(kind: .income, month: m),
                    expense: total(kind: .expense, month: m)
                )
            )
        }
        return points
    }

    func monthsToGoal(_ goal: Goal) -> Int? {
        let left = goal.target - goal.saved
        if left <= 0 { return 0 }
        let now = Date()
        let rate = total(kind: .income, month: now) - total(kind: .expense, month: now)
        guard rate > 0 else { return nil }
        return Int((left / rate).rounded(.up))
    }
}
