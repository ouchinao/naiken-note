import DesignSystem
import Domain
import SwiftUI

public struct PropertyDetailView: View {
    private enum Tab: Hashable, CaseIterable {
        case photos
        case measurements
        case checklist

        var title: LocalizedStringKey {
            switch self {
            case .photos:
                return "写真"
            case .measurements:
                return "採寸"
            case .checklist:
                return "チェック"
            }
        }
    }

    @State private var viewModel: PropertyDetailViewModel
    @State private var photosViewModel: PhotosTabViewModel
    @State private var measurementsViewModel: MeasurementsTabViewModel
    @State private var checklistViewModel: ChecklistTabViewModel
    @State private var tab: Tab = .photos
    @State private var isConfirmingDelete = false
    @Environment(Router.self) private var router

    public init(
        viewModel: PropertyDetailViewModel,
        photosViewModel: PhotosTabViewModel,
        measurementsViewModel: MeasurementsTabViewModel,
        checklistViewModel: ChecklistTabViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
        _photosViewModel = State(initialValue: photosViewModel)
        _measurementsViewModel = State(initialValue: measurementsViewModel)
        _checklistViewModel = State(initialValue: checklistViewModel)
    }

    public var body: some View {
        content
            .navigationTitle(viewModel.property?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task { await viewModel.load() }
            .task { await viewModel.observeChanges() }
            .onChange(of: viewModel.isDeleted) { _, isDeleted in
                if isDeleted {
                    router.pop()
                }
            }
            .confirmationDialog("この物件を削除しますか？", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button("削除", role: .destructive) {
                    Task { await viewModel.delete() }
                }
            } message: {
                Text("写真・採寸・チェック結果もすべて削除されます")
            }
            .alert(
                "確認",
                isPresented: $viewModel.isNoticePresented,
                presenting: viewModel.notice
            ) { _ in
                Button("閉じる", role: .cancel) {}
            } message: { notice in
                switch notice {
                case .failed(let message):
                    Text(message)
                }
            }
    }

    // MARK: - Private

    @ViewBuilder
    private var content: some View {
        if let property = viewModel.property {
            VStack(spacing: 0) {
                PropertySummaryHeader(property: property)
                Picker("表示", selection: $tab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, Spacing.small)
                tabContent(for: property)
                    .frame(maxHeight: .infinity)
            }
        } else if viewModel.hasLoaded {
            ContentUnavailableView("物件が見つかりません", systemImage: "house", description: Text("別の端末で削除された可能性があります"))
        } else {
            ProgressView()
        }
    }

    @ViewBuilder
    private func tabContent(for property: Property) -> some View {
        switch tab {
        case .photos:
            PhotosTabView(viewModel: photosViewModel, property: property)
        case .measurements:
            MeasurementsTabView(viewModel: measurementsViewModel, property: property)
        case .checklist:
            ChecklistTabView(viewModel: checklistViewModel, property: property)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    router.present(.propertyEditor(id: viewModel.propertyID))
                } label: {
                    Label("編集", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    isConfirmingDelete = true
                } label: {
                    Label("削除", systemImage: "trash")
                }
            } label: {
                Label("その他", systemImage: "ellipsis.circle")
            }
            .disabled(viewModel.property == nil)
        }
    }
}

private struct PropertySummaryHeader: View {
    let property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            Text(conditions)
                .font(.headline)
            Text(DisplayFormat.access(station: property.nearestStation, walkMinutes: property.walkMinutes))
                .font(.subheadline)
            Text("内見: \(DisplayFormat.visitDate(property.visitedAt))")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !property.memo.isEmpty {
                Text(property.memo)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .accessibilityElement(children: .combine)
    }

    private var conditions: String {
        return [
            DisplayFormat.rent(property.rent),
            DisplayFormat.layout(property.layout),
            DisplayFormat.area(property.areaSquareMeters),
        ].joined(separator: " / ")
    }
}
