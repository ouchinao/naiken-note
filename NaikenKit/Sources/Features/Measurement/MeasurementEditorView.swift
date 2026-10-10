import DesignSystem
import Domain
import SwiftUI

public struct MeasurementEditorView: View {
    @State private var viewModel: MeasurementEditorViewModel
    @Environment(Router.self) private var router

    public init(viewModel: MeasurementEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            form
                .navigationTitle(viewModel.isNew ? "採寸を追加" : "採寸を編集")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("キャンセル") { router.dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            Task { await viewModel.save() }
                        }
                    }
                }
        }
        .task { await viewModel.load() }
        .onChange(of: viewModel.didSave) { _, didSave in
            if didSave {
                router.dismiss()
            }
        }
        .alert("確認", isPresented: $viewModel.isNoticePresented, presenting: viewModel.notice) { _ in
            Button("閉じる", role: .cancel) {}
        } message: { notice in
            switch notice {
            case .invalidInput(let message), .failed(let message):
                Text(message)
            }
        }
    }

    // MARK: - Private

    private var form: some View {
        Form {
            Section("どこの寸法か") {
                TextField("例: リビングの窓の幅", text: $viewModel.label)
                Menu("定型から選ぶ") {
                    ForEach(MeasurementLabelPreset.all, id: \.self) { preset in
                        Button(preset) { viewModel.label = preset }
                    }
                }
            }
            Section("寸法") {
                HStack(spacing: Spacing.xSmall) {
                    TextField("1690", text: $viewModel.valueText)
                        .keyboardType(.numberPad)
                    Text("mm")
                        .foregroundStyle(.secondary)
                }
            }
            Section("メモ") {
                TextField("例: レールの内側で測った", text: $viewModel.note, axis: .vertical)
            }
            if !viewModel.photos.isEmpty {
                Section("写真") {
                    Picker("どの写真の寸法か", selection: $viewModel.photoID) {
                        Text("なし").tag(UUID?.none)
                        ForEach(viewModel.photos) { photo in
                            Text(photoLabel(photo)).tag(UUID?.some(photo.id))
                        }
                    }
                }
            }
        }
    }

    private func photoLabel(_ photo: Photo) -> String {
        let time = photo.takenAt.formatted(date: .omitted, time: .shortened)
        if photo.caption.isEmpty {
            return "\(photo.roomTag.title) \(time)"
        }
        return "\(photo.roomTag.title) \(photo.caption)"
    }
}
