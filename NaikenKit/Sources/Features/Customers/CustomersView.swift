import DesignSystem
import Domain
import SwiftUI

public struct CustomersView: View {
    @State private var viewModel: CustomersViewModel
    @State private var isAdding = false
    @State private var renameTarget: Customer?
    @State private var nameText = ""
    @Environment(Router.self) private var router

    public init(viewModel: CustomersViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        list
            .navigationTitle("顧客フォルダ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        nameText = ""
                        isAdding = true
                    } label: {
                        Label("顧客を追加", systemImage: "plus")
                    }
                }
            }
            .task { await viewModel.load() }
            .task { await viewModel.observeChanges() }
            .alert("顧客を追加", isPresented: $isAdding) {
                TextField("お客様の名前", text: $nameText)
                Button("追加") {
                    let name = nameText
                    Task { await viewModel.add(name: name) }
                }
                Button("キャンセル", role: .cancel) {}
            }
            .alert("名前を変更", isPresented: isRenaming) {
                TextField("お客様の名前", text: $nameText)
                Button("保存") { rename() }
                Button("キャンセル", role: .cancel) {}
            }
            .alert(
                "確認",
                isPresented: $viewModel.isNoticePresented,
                presenting: viewModel.notice
            ) { notice in
                if case .proRequired = notice {
                    Button("Proにする") { router.present(.paywall) }
                }
                Button("閉じる", role: .cancel) {}
            } message: { notice in
                switch notice {
                case .proRequired:
                    Text("顧客フォルダはProで使えます")
                case .emptyName:
                    Text("名前を入力してください")
                case .failed(let message):
                    Text(message)
                }
            }
    }

    // MARK: - Private

    @ViewBuilder
    private var list: some View {
        if viewModel.hasLoaded && viewModel.customers.isEmpty {
            ContentUnavailableView(
                "顧客フォルダがありません",
                systemImage: "folder",
                description: Text("お客様ごとにフォルダを作ると、物件一覧をフォルダで絞り込めます")
            )
        } else {
            List {
                ForEach(viewModel.customers) { customer in
                    Button(customer.name) {
                        nameText = customer.name
                        renameTarget = customer
                    }
                }
                .onDelete { offsets in
                    let targets = offsets.map { viewModel.customers[$0] }
                    Task { await viewModel.delete(targets) }
                }
            }
        }
    }

    private var isRenaming: Binding<Bool> {
        return Binding {
            return renameTarget != nil
        } set: { isPresented in
            if !isPresented {
                renameTarget = nil
            }
        }
    }

    private func rename() {
        guard let renameTarget else {
            return
        }
        let name = nameText
        Task { await viewModel.rename(renameTarget, to: name) }
    }
}
