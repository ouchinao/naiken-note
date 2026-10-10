import DesignSystem
import Domain
import SwiftUI

struct ChecklistTabView: View {
    @Bindable private var viewModel: ChecklistTabViewModel
    private let property: Property

    init(viewModel: ChecklistTabViewModel, property: Property) {
        self.viewModel = viewModel
        self.property = property
    }

    var body: some View {
        List {
            ForEach(CheckItem.Category.allCases, id: \.self) { category in
                Section(category.title) {
                    ForEach(CheckItemCatalog.items(in: category)) { item in
                        ChecklistRow(
                            item: item,
                            rating: viewModel.result(for: item, in: property)?.rating,
                            note: noteBinding(for: item)
                        ) { rating in
                            Task { await viewModel.setRating(rating, for: item, in: property) }
                        } onNoteCommit: {
                            Task { await viewModel.commitNote(for: item, in: property) }
                        }
                    }
                }
            }
        }
        .onChange(of: property) { _, property in
            viewModel.didReload(property)
        }
        .alert("確認", isPresented: $viewModel.isNoticePresented, presenting: viewModel.notice) { _ in
            Button("閉じる", role: .cancel) {}
        } message: { notice in
            switch notice {
            case .failed(let message):
                Text(message)
            }
        }
    }

    // MARK: - Private

    private func noteBinding(for item: CheckItem) -> Binding<String> {
        return Binding {
            return viewModel.note(for: item, in: property)
        } set: { note in
            viewModel.editNote(note, for: item)
        }
    }
}

private struct ChecklistRow: View {
    private static let pickerWidth: CGFloat = 180

    private let item: CheckItem
    private let rating: CheckResult.Rating?
    @Binding private var note: String
    private let onRatingChange: (CheckResult.Rating?) -> Void
    private let onNoteCommit: () -> Void
    @FocusState private var isEditingNote: Bool

    init(
        item: CheckItem,
        rating: CheckResult.Rating?,
        note: Binding<String>,
        onRatingChange: @escaping (CheckResult.Rating?) -> Void,
        onNoteCommit: @escaping () -> Void
    ) {
        self.item = item
        self.rating = rating
        _note = note
        self.onRatingChange = onRatingChange
        self.onNoteCommit = onNoteCommit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text(item.title)
                Spacer()
                Picker(item.title, selection: ratingBinding) {
                    Text("−").tag(CheckResult.Rating?.none)
                    ForEach(CheckResult.Rating.allCases.reversed(), id: \.self) { rating in
                        Text(rating.symbol)
                            .accessibilityLabel(rating.accessibilityName)
                            .tag(CheckResult.Rating?.some(rating))
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: Self.pickerWidth)
            }
            TextField("メモ", text: $note)
                .font(.footnote)
                .focused($isEditingNote)
                .onSubmit { onNoteCommit() }
        }
        .onChange(of: isEditingNote) { _, isEditing in
            if !isEditing {
                onNoteCommit()
            }
        }
        .onDisappear { onNoteCommit() }
    }

    // MARK: - Private

    private var ratingBinding: Binding<CheckResult.Rating?> {
        return Binding {
            return rating
        } set: { newValue in
            onRatingChange(newValue)
        }
    }
}
