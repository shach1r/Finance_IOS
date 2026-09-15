import SwiftUI

struct TransactionsView: View {

    @EnvironmentObject var state: AppState
    @State private var showingAdd = false
    private let now = Date()

    var body: some View {
        NavigationStack {
            Group {
                let items = state.transactions(inMonth: now)
                if items.isEmpty {
                    emptyState
                } else {
                    list(items)
                }
            }
            .navigationTitle("Операции")
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
                AddTransactionSheet()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Пока нет операций")
                .font(.headline)
            Text("Нажмите «плюс», чтобы добавить первую.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func list(_ items: [Transaction]) -> some View {
        let groups = Dictionary(grouping: items) { tx in
            Calendar.current.startOfDay(for: tx.date)
        }
        let days = groups.keys.sorted(by: >)

        return List {
            ForEach(days, id: \.self) { day in
                Section(Format.day(day)) {
                    ForEach(groups[day] ?? []) { tx in
                        row(tx)
                    }
                    .onDelete { offsets in
                        delete(offsets, in: groups[day] ?? [])
                    }
                }
            }
        }
    }

    private func row(_ tx: Transaction) -> some View {
        let cat = state.category(tx.categoryId)
        return HStack {
            Text(cat?.emoji ?? "❓")
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(cat?.name ?? "Без категории")
                    .font(.body)
                if !tx.note.isEmpty {
                    Text(tx.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(Format.signed(tx.amount, kind: tx.kind))
                .font(.body.weight(.semibold))
                .foregroundStyle(tx.kind == .income ? Color.green : Color.primary)
        }
    }

    private func delete(_ offsets: IndexSet, in dayItems: [Transaction]) {
        for i in offsets {
            state.deleteTransaction(dayItems[i])
        }
    }
}
