import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class CustomersViewModel {
    enum Notice: Equatable {
        case proRequired
        case emptyName
        case failed(message: String)
    }

    // MARK: - State

    private(set) var customers: [Customer] = []
    private(set) var hasLoaded = false
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

    // MARK: - Init

    private let fetchCustomers: FetchCustomersUseCase
    private let saveCustomer: SaveCustomerUseCase
    private let deleteCustomer: DeleteCustomerUseCase
    private let storeChanges: any StoreChangeObserving

    public init(
        fetchCustomers: FetchCustomersUseCase,
        saveCustomer: SaveCustomerUseCase,
        deleteCustomer: DeleteCustomerUseCase,
        storeChanges: any StoreChangeObserving
    ) {
        self.fetchCustomers = fetchCustomers
        self.saveCustomer = saveCustomer
        self.deleteCustomer = deleteCustomer
        self.storeChanges = storeChanges
    }

    // MARK: - Actions

    func load() async {
        defer {
            hasLoaded = true
        }
        do {
            customers = try await fetchCustomers.execute()
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    func observeChanges() async {
        for await _ in storeChanges.changes {
            try? await Task.sleep(for: StoreChangeDebounce.interval)
            await load()
        }
    }

    func add(name: String) async {
        await save(Customer(id: UUID(), name: name.trimmingCharacters(in: .whitespacesAndNewlines), createdAt: Date()))
    }

    func rename(_ customer: Customer, to name: String) async {
        var renamed = customer
        renamed.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        await save(renamed)
    }

    func delete(_ targets: [Customer]) async {
        do {
            for customer in targets {
                try await deleteCustomer.execute(id: customer.id)
            }
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    // MARK: - Private

    private func save(_ customer: Customer) async {
        do {
            try await saveCustomer.execute(customer)
        } catch SaveCustomerUseCase.Failure.proRequired {
            notice = .proRequired
        } catch SaveCustomerUseCase.Failure.emptyName {
            notice = .emptyName
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
