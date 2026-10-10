import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class PaywallViewModel {
    enum Notice {
        case pending
        case restored
        case failed(message: String)
    }

    // MARK: - State

    private(set) var products: [PurchasableProduct] = []
    private(set) var isLoading = false
    private var purchasingID: String?
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

    var isPurchasing: Bool {
        return purchasingID != nil
    }

    // MARK: - Init

    private let loadProducts: LoadProductsUseCase
    private let purchaseProduct: PurchaseProductUseCase
    private let restorePurchases: RestorePurchasesUseCase
    private let entitlementStore: EntitlementStore

    public init(
        loadProducts: LoadProductsUseCase,
        purchaseProduct: PurchaseProductUseCase,
        restorePurchases: RestorePurchasesUseCase,
        entitlementStore: EntitlementStore
    ) {
        self.loadProducts = loadProducts
        self.purchaseProduct = purchaseProduct
        self.restorePurchases = restorePurchases
        self.entitlementStore = entitlementStore
    }

    // MARK: - Actions

    func load() async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            products = try await loadProducts.execute()
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    func purchase(_ product: PurchasableProduct) async {
        purchasingID = product.id
        defer {
            purchasingID = nil
        }
        do {
            switch try await purchaseProduct.execute(productID: product.id) {
            case .purchased:
                await entitlementStore.refresh()
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
        do {
            try await restorePurchases.execute()
            await entitlementStore.refresh()
            notice = .restored
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
