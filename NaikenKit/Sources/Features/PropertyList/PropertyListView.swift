import DesignSystem
import Domain
import SwiftUI

public struct PropertyListView: View {
    @State private var viewModel: PropertyListViewModel
    @Environment(Router.self) private var router
    @Environment(EntitlementStore.self) private var entitlementStore

    public init(viewModel: PropertyListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle("内見ノート")
            .toolbar { toolbarContent }
            .safeAreaInset(edge: .bottom) { compareBar }
            .task { await viewModel.load() }
            .task { await viewModel.observeChanges() }
            .onChange(of: viewModel.filter) {
                Task { await viewModel.load() }
            }
            .onChange(of: entitlementStore.current) { _, entitlement in
                // 絞り込みを残さないのは、Pro が切れるとフォルダのメニューが消えて、ユーザーが解除できなくなるため
                if !entitlement.canUseCustomerFolders {
                    viewModel.filter = .all
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
                case .failed(let message):
                    Text(message)
                }
            }
    }

    // MARK: - Private

    @ViewBuilder
    private var content: some View {
        if viewModel.hasLoaded && viewModel.properties.isEmpty {
            ContentUnavailableView {
                Label("物件がありません", systemImage: "house")
            } description: {
                Text("右上の＋から、内見した物件を登録しましょう")
            }
        } else {
            List(viewModel.properties) { property in
                Button {
                    select(property)
                } label: {
                    PropertyRow(
                        property: property,
                        thumbnail: viewModel.thumbnails[property.id],
                        customerName: viewModel.customerName(of: property),
                        isSelected: viewModel.isSelecting ? viewModel.isSelected(property) : nil
                    )
                }
                .buttonStyle(.plain)
            }
            .overlay {
                if viewModel.isLoading && !viewModel.hasLoaded {
                    ProgressView()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                router.push(.settings)
            } label: {
                Label("設定", systemImage: "gearshape")
            }
        }
        if entitlementStore.current.canUseCustomerFolders {
            ToolbarItem(placement: .topBarLeading) {
                folderMenu
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            if viewModel.isSelecting {
                Button("キャンセル") { viewModel.finishSelecting() }
            } else {
                Button("比較") { viewModel.startSelecting() }
                    .disabled(!viewModel.canStartSelecting)
                Button {
                    Task { await startAdding() }
                } label: {
                    Label("物件を追加", systemImage: "plus")
                }
            }
        }
    }

    private var folderMenu: some View {
        Menu {
            Picker("フォルダ", selection: $viewModel.filter) {
                Text("すべて").tag(CustomerFilter.all)
                ForEach(viewModel.customers) { customer in
                    Text(customer.name).tag(CustomerFilter.customer(customer.id))
                }
                Text("未分類").tag(CustomerFilter.unassigned)
            }
        } label: {
            Label("フォルダ", systemImage: "folder")
        }
    }

    @ViewBuilder
    private var compareBar: some View {
        if viewModel.isSelecting {
            Button("比較する（\(viewModel.selectedIDs.count)/\(Limits.comparisonMaximumCount)）") {
                let ids = viewModel.selectedIDs
                viewModel.finishSelecting()
                router.push(.comparison(ids: ids))
            }
            .buttonStyle(.primary)
            .disabled(!viewModel.canCompare)
            .padding()
            .background(.bar)
        }
    }

    private func select(_ property: Property) {
        if viewModel.isSelecting {
            viewModel.toggleSelection(of: property)
        } else {
            router.push(.propertyDetail(id: property.id))
        }
    }

    private func startAdding() async {
        if await viewModel.prepareToAdd() {
            router.present(.propertyEditor(id: nil))
        }
    }
}
