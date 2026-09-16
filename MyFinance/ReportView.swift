import SwiftUI

struct ReportView: View {

    @EnvironmentObject var state: AppState
    private let now = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    breakdownCard
                    dynamicsCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Отчёт")
        }
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Расходы по категориям")
                .font(.headline)

            let report = state.expenseReport(month: now)
            if report.isEmpty {
                Text("В этом месяце расходов пока нет.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(report) { item in
                    VStack(spacing: 6) {
                        HStack {
                            Text("\(item.category.emoji) \(item.category.name)")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(item.share * 100)) %")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(Format.amount(item.amount))
                                .font(.subheadline.weight(.semibold))
                        }
                        ProgressView(value: item.share)
                            .tint(.accentColor)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var dynamicsCard: some View {
        let points = state.lastSixMonths()
        let maxValue = max(points.map { max($0.income, $0.expense) }.max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Динамика за полгода")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(points) { p in
                    VStack(spacing: 4) {
                        HStack(alignment: .bottom, spacing: 3) {
                            bar(value: p.income, maxValue: maxValue, color: .green)
                            bar(value: p.expense, maxValue: maxValue, color: .red)
                        }
                        .frame(height: 120, alignment: .bottom)
                        Text(Format.shortMonth(p.month))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: 16) {
                legend(color: .green, title: "Доход")
                legend(color: .red, title: "Расход")
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func bar(value: Double, maxValue: Double, color: Color) -> some View {
        let height = maxValue > 0 ? CGFloat(value / maxValue) * 120 : 0
        return RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: 12, height: max(height, value > 0 ? 3 : 0))
    }

    private func legend(color: Color, title: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }
}
