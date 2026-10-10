import DesignSystem
import Domain
import SwiftUI

public struct PaywallView: View {
    @State private var viewModel: PaywallViewModel
    @Environment(Router.self) private var router

    public init(viewModel: PaywallViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xLarge) {
                    PlanStatusView(entitlement: viewModel.entitlement)
                    PlanFeaturesView()
                    productButtons
                    Button("購入を復元") {
                        Task { await viewModel.restore() }
                    }
                    .disabled(viewModel.isRestoring)
                    .frame(maxWidth: .infinity)
                    SubscriptionTermsView()
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
        } else if viewModel.canRetryLoading {
            VStack(spacing: Spacing.small) {
                Text("商品を読み込めませんでした。通信できる場所でもう一度お試しください")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("再読み込み") {
                    Task { await viewModel.load() }
                }
            }
            .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: Spacing.medium) {
                ForEach(viewModel.products) { product in
                    Button {
                        Task { await viewModel.purchase(product) }
                    } label: {
                        Text(title(of: product))
                    }
                    .buttonStyle(.primary)
                    .disabled(!viewModel.canPurchase(product))
                }
            }
        }
    }

    private func title(of product: PurchasableProduct) -> String {
        if product.isSubscription {
            return String(localized: "\(product.displayName) \(product.displayPrice)/月", bundle: .module)
        }
        return "\(product.displayName) \(product.displayPrice)"
    }

    private func isOwned(_ product: PurchasableProduct) -> Bool {
        switch entitlementStore.current {
        case .free:
            return false
        case .unlocked:
            return !product.isSubscription
        case .pro:
            return true
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
            Text("Proで増えること")
                .font(.headline)
                .padding(.top, Spacing.small)
            Label("お客様ごとのフォルダで物件を整理", systemImage: "folder")
        }
    }
}

private struct SubscriptionTermsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Proは月額の自動更新サブスクリプションです。購入の確定時にApple IDに請求され、期間終了の24時間前までに解約しない限り自動で更新されます。解約はApp Storeのアカウント設定から行えます。")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: Spacing.large) {
                if let termsOfUse = AppLinks.termsOfUse {
                    Link("利用規約", destination: termsOfUse)
                }
                if let privacyPolicy = AppLinks.privacyPolicy {
                    Link("プライバシーポリシー", destination: privacyPolicy)
                }
            }
            .font(.caption)
        }
    }
}
