import DesignSystem
import Domain
import SwiftUI

/// 「無料版でできること / 解除で増えること」を並べ、購入前に価格を明示する
public struct PaywallView: View {
    @State private var viewModel: PaywallViewModel
    @Environment(Router.self) private var router
    @Environment(EntitlementStore.self) private var entitlementStore

    public init(viewModel: PaywallViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xLarge) {
                    PlanStatusView(entitlement: entitlementStore.current)
                    PlanFeaturesView()
                    productButtons
                    Button("購入を復元") {
                        Task { await viewModel.restore() }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationTitle("機能を解除")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { router.dismiss() }
                }
            }
        }
        .task { await viewModel.load() }
        .onChange(of: viewModel.didPurchase) { _, didPurchase in
            if didPurchase {
                router.dismiss()
            }
        }
        .alert("確認", isPresented: $viewModel.isNoticePresented, presenting: viewModel.notice) { _ in
            Button("閉じる", role: .cancel) {}
        } message: { notice in
            switch notice {
            case .pending:
                Text("購入の承認を待っています。承認されると自動で解除されます")
            case .restored:
                Text("購入を復元しました")
            case .failed(let message):
                Text(message)
            }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var productButtons: some View {
        if viewModel.isLoading && viewModel.products.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: Spacing.medium) {
                ForEach(viewModel.products) { product in
                    Button {
                        Task { await viewModel.purchase(product) }
                    } label: {
                        Text("\(product.displayName) \(product.displayPrice)")
                    }
                    .buttonStyle(.primary)
                    .disabled(viewModel.isPurchasing || entitlementStore.current != .free)
                }
            }
        }
    }
}

private struct PlanStatusView: View {
    let entitlement: Entitlement

    var body: some View {
        HStack {
            Image(systemName: entitlement == .free ? "lock" : "checkmark.seal.fill")
                .foregroundStyle(Color.brand)
            Text(title)
                .font(.headline)
        }
    }

    private var title: LocalizedStringKey {
        switch entitlement {
        case .free:
            return "いまは無料版です"
        case .unlocked:
            return "機能を解除済みです"
        case .pro:
            return "Proを利用中です"
        }
    }
}

private struct PlanFeaturesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("無料版でできること")
                .font(.headline)
            Label("物件\(Limits.freePropertyCount)件まで登録", systemImage: "house")
            Label("写真・採寸・チェックリスト", systemImage: "camera")
            Label("iCloudへのバックアップ", systemImage: "icloud")
            Text("解除で増えること")
                .font(.headline)
                .padding(.top, Spacing.small)
            Label("物件を何件でも登録", systemImage: "infinity")
            Label("比較表を画像にしてLINEなどで送る", systemImage: "square.and.arrow.up")
        }
    }
}
