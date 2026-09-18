import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var state: AppState
    @State private var startingBalanceText = ""
    @State private var showingAddCategory = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Оформление") {
                    Picker("Тема", selection: themeBinding) {
                        ForEach(ThemeChoice.allCases, id: \.self) { t in
                            Text(t.title).tag(t)
                        }
                    }
                }

                Section("Стартовый баланс") {
                    HStack {
                        TextField("0", text: $startingBalanceText)
                            .keyboardType(.decimalPad)
                        Text("₽").foregroundStyle(.secondary)
                        Button("Сохранить") { saveStartingBalance() }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                    }
                }

                Section("Категории") {
                    ForEach(state.categories) { cat in
                        HStack {
                            Text("\(cat.emoji) \(cat.name)")
                            Spacer()
                            Text(cat.kind.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let limit = cat.limit {
                                Text(Format.amount(limit))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        for i in offsets { state.deleteCategory(state.categories[i]) }
                    }

                    Button {
                        showingAddCategory = true
                    } label: {
                        Label("Добавить категорию", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Настройки")
            .onAppear {
                startingBalanceText = String(Int(state.settings.startingBalance))
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet()
            }
        }
    }

    private var themeBinding: Binding<ThemeChoice> {
        Binding(
            get: { state.settings.theme },
            set: { new in
                var s = state.settings
                s.theme = new
                state.updateSettings(s)
            }
        )
    }

    private func saveStartingBalance() {
        let value = Double(startingBalanceText.replacingOccurrences(of: ",", with: ".")) ?? 0
        var s = state.settings
        s.startingBalance = value
        state.updateSettings(s)
    }
}

struct AddCategorySheet: View {

    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = "🏷️"
    @State private var kind: TxKind = .expense
    @State private var limitText = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $name)
                TextField("Эмодзи", text: $emoji)
                Picker("Тип", selection: $kind) {
                    ForEach(TxKind.allCases, id: \.self) { k in
                        Text(k.title).tag(k)
                    }
                }
                .pickerStyle(.segmented)

                if kind == .expense {
                    HStack {
                        TextField("Лимит в месяц (необязательно)", text: $limitText)
                            .keyboardType(.decimalPad)
                        Text("₽").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Новая категория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { save() }
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func save() {
        let limit = Double(limitText.replacingOccurrences(of: ",", with: "."))
        let category = Category(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            kind: kind,
            emoji: emoji.isEmpty ? "🏷️" : emoji,
            limit: kind == .expense ? limit : nil
        )
        state.addCategory(category)
        dismiss()
    }
}
