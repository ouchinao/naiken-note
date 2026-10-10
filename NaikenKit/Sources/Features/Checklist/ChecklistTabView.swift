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
                        ChecklistRow(item: item, result: property.checkResult(forItemKey: item.id)) { rating in
                            Task { await viewModel.setRating(rating, for: item, in: property) }
                        } onNoteCommit: { note in
                            Task { await viewModel.setNote(note, for: item, in: property) }
                        }
                    }
                }
            }
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
}

private struct ChecklistRow: View {
    private static let pickerWidth: CGFloat = 180

    private let item: CheckItem
    private let result: CheckResult?
    private let onRatingChange: (CheckResult.Rating?) -> Void
    private let onNoteCommit: (String) -> Void
    @State private var note = ""

    init(
        item: CheckItem,
        result: CheckResult?,
        onRatingChange: @escaping (CheckResult.Rating?) -> Void,
        onNoteCommit: @escaping (String) -> Void
    ) {
        self.item = item
        self.result = result
        self.onRatingChange = onRatingChange
        self.onNoteCommit = onNoteCommit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text(item.title)
                Spacer()
                Picker(item.title, selection: rating) {
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
                .onSubmit { onNoteCommit(note) }
        }
        .onAppear { note = result?.note ?? "" }
        .onDisappear {
            if note != (result?.note ?? "") {
                onNoteCommit(note)
            }
        }
    }

    private var rating: Binding<CheckResult.Rating?> {
        return Binding {
            return result?.rating
        } set: { newValue in
            onRatingChange(newValue)
        }
    }
}
