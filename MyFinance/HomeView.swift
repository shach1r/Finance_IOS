import SwiftUI

struct HomeView: View {

    @EnvironmentObject var state: AppState
    private let now = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balanceCard
                    monthSummary
                    limitsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Мои Финансы")
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 6) {
            Text("Баланс")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(Format.amount(state.balance))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(state.balance >= 0 ? Color.primary : Color.red)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var monthSummary: some View {
        HStack(spacing: 12) {
            summaryTile(
                title: "Доход",
                value: state.total(kind: .income, month: now),
                color: .green
            )
            summaryTile(
                title: "Расход",
                value: state.total(kind: .expense, month: now),
                color: .red
            )
        }
    }

    private func summaryTile(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(Format.amount(value))
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var limitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Лимиты месяца")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            let withLimit = state.categories.filter { $0.kind == .expense && $0.limit != nil }
            if withLimit.isEmpty {
                Text("Лимиты не заданы. Добавьте их в настройках категорий.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(withLimit) { cat in
                    limitRow(cat)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func limitRow(_ cat: Category) -> some View {
        let limit = cat.limit ?? 0
        let spent = state.spent(categoryId: cat.id, month: now)
        let ratio = limit > 0 ? min(spent / limit, 1) : 0
        let color: Color = spent > limit ? .red : (ratio >= 0.8 ? .orange : .green)

        return VStack(spacing: 6) {
            HStack {
                Text("\(cat.emoji) \(cat.name)")
                    .font(.subheadline)
                Spacer()
                Text("\(Format.amount(spent)) / \(Format.amount(limit))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: ratio)
                .tint(color)
        }
    }
}
