import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class PaywallViewModel {
    enum Notice: Equatable {
        case pending
        case restored
        case failed(message: String)
    }

    // MARK: - State

    private(set) var products: [PurchasableProduct] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private var purchasingID: String?
    private(set) var isRestoring = false
    private(set) var didPurchase = false
    private(set) var notice: Notice?

    var isNoticePresented: Bool {
        get {
            return notice != nil
        }
        set {
            if !newValue {
                notice = nil
            }
        }
    }

    var entitlement: Entitlement {
        return entitlementState.current
    }

    var isPurchasing: Bool {
        return purchasingID != nil
    }

    var canRetryLoading: Bool {
        return hasLoaded && !isLoading && products.isEmpty
    }

    // MARK: - Init

    private let loadProducts: LoadProductsUseCase
    private let purchaseProduct: PurchaseProductUseCase
    private let restorePurchases: RestorePurchasesUseCase
    private let entitlementState: any EntitlementState

    public init(
        loadProducts: LoadProductsUseCase,
        purchaseProduct: PurchaseProductUseCase,
        restorePurchases: RestorePurchasesUseCase,
        entitlementState: any EntitlementState
    ) {
        self.loadProducts = loadProducts
        self.purchaseProduct = purchaseProduct
        self.restorePurchases = restorePurchases
        self.entitlementState = entitlementState
    }

    // MARK: - Actions

    func load() async {
        isLoading = true
        defer {
            isLoading = false
            hasLoaded = true
        }
        do {
            products = try await loadProducts.execute()
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    func canPurchase(_ product: PurchasableProduct) -> Bool {
        return !isPurchasing && !isRestoring && !isOwned(product)
    }

    func purchase(_ product: PurchasableProduct) async {
        guard canPurchase(product) else {
            return
        }
        purchasingID = product.id
        defer {
            purchasingID = nil
        }
        do {
            switch try await purchaseProduct.execute(productID: product.id) {
            case .purchased:
                await entitlementState.refresh()
                didPurchase = true
            case .pending:
                notice = .pending
            case .cancelled:
                return
            }
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    func restore() async {
        guard !isRestoring else {
            return
        }
        isRestoring = true
        defer {
            isRestoring = false
        }
        do {
            try await restorePurchases.execute()
            await entitlementState.refresh()
            notice = .restored
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    // MARK: - Private

    private func isOwned(_: PurchasableProduct) -> Bool {
        return entitlementState.current != .free
    }
}
