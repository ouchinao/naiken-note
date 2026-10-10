import DesignSystem
import Domain
import SwiftUI

public struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(Router.self) private var router
    @Environment(EntitlementStore.self) private var entitlementStore

    public init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        List {
            Section("iCloud同期") {
                LabeledContent("状態", value: cloudStatusText)
            }
            purchaseSection
            if entitlementStore.current.canUseCustomerFolders {
                Section("Pro") {
                    Button("顧客フォルダを管理") { router.push(.customers) }
                }
            }
            Section("サポート") {
                if let contact = AppLinks.contact {
                    Link("問い合わせ", destination: contact)
                }
                if let privacyPolicy = AppLinks.privacyPolicy {
                    Link("プライバシーポリシー", destination: privacyPolicy)
                }
                LabeledContent("バージョン", value: appVersion)
            }
        }
        .navigationTitle("設定")
        .onAppear { viewModel.load() }
        .alert("確認", isPresented: $viewModel.isNoticePresented, presenting: viewModel.notice) { _ in
            Button("閉じる", role: .cancel) {}
        } message: { notice in
            switch notice {
            case .restored:
                Text("購入を復元しました")
            case .failed(let message):
                Text(message)
            }
        }
    }

    // MARK: - Private

    private var purchaseSection: some View {
        Section("購入") {
            LabeledContent("プラン", value: planText)
            if entitlementStore.current != .pro {
                Button("機能を解除する") { router.present(.paywall) }
            }
            Button("購入を復元") {
                Task { await viewModel.restore() }
            }
            .disabled(viewModel.isRestoring)
        }
    }

    private var cloudStatusText: String {
        switch viewModel.cloudStatus {
        case .enabled:
            return String(localized: "有効", bundle: .module)
        case .signedOut:
            return String(localized: "iCloudにサインインしていません", bundle: .module)
        }
    }

    private var planText: String {
        switch entitlementStore.current {
        case .free:
            return String(localized: "無料版", bundle: .module)
        case .unlocked:
            return String(localized: "解除済み", bundle: .module)
        case .pro:
            return String(localized: "Pro", bundle: .module)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
        return "\(version) (\(build))"
    }
}
