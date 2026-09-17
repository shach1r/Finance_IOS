import SwiftUI

struct GoalsView: View {

    @EnvironmentObject var state: AppState
    @State private var showingAdd = false
    @State private var topUpTarget: Goal?
    @State private var topUpText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if state.goals.isEmpty {
                        Text("Целей пока нет. Добавьте первую по кнопке «плюс».")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    } else {
                        ForEach(state.goals) { goal in
                            card(goal)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Цели")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddGoalSheet()
            }
            .alert("Пополнить цель", isPresented: Binding(
                get: { topUpTarget != nil },
                set: { if !$0 { topUpTarget = nil } }
            )) {
                TextField("Сумма", text: $topUpText)
                    .keyboardType(.decimalPad)
                Button("Отмена", role: .cancel) { topUpTarget = nil }
                Button("Пополнить") { confirmTopUp() }
            }
        }
    }

    private func card(_ goal: Goal) -> some View {
        let ratio = goal.target > 0 ? min(goal.saved / goal.target, 1) : 0
        let months = state.monthsToGoal(goal)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(goal.emoji) \(goal.name)")
                    .font(.headline)
                Spacer()
                Text("\(Int(ratio * 100)) %")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: ratio)
                .tint(.accentColor)

            HStack {
                Text("\(Format.amount(goal.saved)) из \(Format.amount(goal.target))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(forecastText(months))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button {
                    topUpText = ""
                    topUpTarget = goal
                } label: {
                    Label("Пополнить", systemImage: "plus.circle")
                        .font(.subheadline)
                }
                Spacer()
                Button(role: .destructive) {
                    state.deleteGoal(goal)
                } label: {
                    Image(systemName: "trash")
                }
            }
            .padding(.top, 2)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func forecastText(_ months: Int?) -> String {
        guard let months else { return "Прогноз недоступен" }
        if months == 0 { return "Цель достигнута" }
        return "≈ \(months) мес."
    }

    private func confirmTopUp() {
        guard let goal = topUpTarget else { return }
        let amount = Double(topUpText.replacingOccurrences(of: ",", with: ".")) ?? 0
        if amount > 0 { state.topUp(goal, by: amount) }
        topUpTarget = nil
    }
}

struct AddGoalSheet: View {

    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = "🎯"
    @State private var targetText = ""

    private var target: Double {
        Double(targetText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $name)
                TextField("Эмодзи", text: $emoji)
                HStack {
                    TextField("Цель, ₽", text: $targetText)
                        .keyboardType(.decimalPad)
                    Text("₽").foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Новая цель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { save() }
                        .disabled(name.isEmpty || target <= 0)
                }
            }
        }
    }

    private func save() {
        let goal = Goal(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: emoji.isEmpty ? "🎯" : emoji,
            target: target
        )
        state.addGoal(goal)
        dismiss()
    }
}
