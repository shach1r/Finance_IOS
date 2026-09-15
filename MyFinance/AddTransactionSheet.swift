import SwiftUI

struct AddTransactionSheet: View {

    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var kind: TxKind = .expense
    @State private var amountText = ""
    @State private var categoryId = ""
    @State private var note = ""
    @State private var date = Date()

    private var visibleCategories: [Category] {
        state.categories.filter { $0.kind == kind }
    }

    private var amount: Double {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var canSave: Bool {
        amount > 0 && !categoryId.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Тип", selection: $kind) {
                        ForEach(TxKind.allCases, id: \.self) { k in
                            Text(k.title).tag(k)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: kind) { _ in categoryId = "" }

                    HStack {
                        TextField("Сумма", text: $amountText)
                            .keyboardType(.decimalPad)
                            .font(.title2.weight(.semibold))
                        Text("₽").foregroundStyle(.secondary)
                    }
                }

                Section("Категория") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                        ForEach(visibleCategories) { cat in
                            chip(cat)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    TextField("Комментарий", text: $note)
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Новая операция")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private func chip(_ cat: Category) -> some View {
        let selected = cat.id == categoryId
        return Button {
            categoryId = cat.id
        } label: {
            Text("\(cat.emoji) \(cat.name)")
                .font(.subheadline)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(selected ? Color.accentColor : Color(.tertiarySystemFill))
                .foregroundStyle(selected ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func save() {
        let tx = Transaction(
            amount: amount,
            kind: kind,
            categoryId: categoryId,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date
        )
        state.addTransaction(tx)
        dismiss()
    }
}
