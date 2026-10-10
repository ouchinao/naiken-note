import DesignSystem
import Domain
import SwiftUI

public struct PropertyEditorView: View {
    @State private var viewModel: PropertyEditorViewModel
    @Environment(Router.self) private var router

    public init(viewModel: PropertyEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            form
                .navigationTitle(viewModel.isNew ? "物件を追加" : "物件を編集")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("キャンセル") { router.dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            Task { await viewModel.save() }
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
                .task { await viewModel.load() }
                .onChange(of: viewModel.didSave) { _, didSave in
                    if didSave {
                        router.dismiss()
                    }
                }
                .alert(
                    "確認",
                    isPresented: $viewModel.isNoticePresented,
                    presenting: viewModel.notice
                ) { notice in
                    if case .limitReached = notice {
                        Button("解除する") { router.present(.paywall) }
                    }
                    Button("閉じる", role: .cancel) {}
                } message: { notice in
                    switch notice {
                    case .limitReached(let limit):
                        Text("無料版で登録できるのは\(limit)件までです")
                    case .invalidInput(let message), .failed(let message):
                        Text(message)
                    }
                }
        }
    }

    // MARK: - Private

    private var form: some View {
        Form {
            Section("基本情報") {
                TextField("物件名(例: A棟201)", text: $viewModel.name)
                DatePicker("内見日時", selection: $viewModel.visitedAt)
            }
            Section("条件") {
                numberField("家賃", unit: "円", placeholder: "85000", text: $viewModel.rentText, keyboard: .numberPad)
                TextField("間取り(例: 1LDK)", text: $viewModel.layout)
                numberField("面積", unit: "㎡", placeholder: "25.5", text: $viewModel.areaText, keyboard: .decimalPad)
                TextField("最寄駅", text: $viewModel.nearestStation)
                numberField("駅から徒歩", unit: "分", placeholder: "7", text: $viewModel.walkMinutesText, keyboard: .numberPad)
            }
            Section("メモ") {
                TextField("気づいたこと", text: $viewModel.memo, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
    }

    private func numberField(
        _ title: LocalizedStringKey,
        unit: LocalizedStringKey,
        placeholder: LocalizedStringKey,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        return LabeledContent(title) {
            HStack(spacing: Spacing.xSmall) {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .multilineTextAlignment(.trailing)
                Text(unit)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
