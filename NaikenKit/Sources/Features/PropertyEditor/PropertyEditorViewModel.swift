import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class PropertyEditorViewModel {
    enum Notice: Equatable {
        case limitReached(limit: Int)
        case proRequired
        case invalidInput(message: String)
        case failed(message: String)
    }

    // MARK: - State

    @ObservationIgnored private var original: Property?
    var name = ""
    var rentText = ""
    var layout = ""
    var areaText = ""
    var nearestStation = ""
    var walkMinutesText = ""
    var visitedAt = Date()
    var memo = ""
    var customerID: UUID?
    private(set) var customers: [Customer] = []
    private var isSaving = false
    private(set) var didSave = false
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

    var isNew: Bool {
        return propertyID == nil
    }

    var canAssignCustomer: Bool {
        return entitlementState.current.canUseCustomerFolders
    }

    var canSave: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    // MARK: - Init

    private let propertyID: UUID?
    private let fetchProperty: FetchPropertyUseCase
    private let addProperty: AddPropertyUseCase
    private let updateProperty: UpdatePropertyUseCase
    private let fetchCustomers: FetchCustomersUseCase
    private let entitlementState: any EntitlementState

    public init(
        propertyID: UUID?,
        fetchProperty: FetchPropertyUseCase,
        addProperty: AddPropertyUseCase,
        updateProperty: UpdatePropertyUseCase,
        fetchCustomers: FetchCustomersUseCase,
        entitlementState: any EntitlementState
    ) {
        self.propertyID = propertyID
        self.fetchProperty = fetchProperty
        self.addProperty = addProperty
        self.updateProperty = updateProperty
        self.fetchCustomers = fetchCustomers
        self.entitlementState = entitlementState
    }

    // MARK: - Actions

    func load() async {
        do {
            customers = try await fetchCustomers.execute()
            if let propertyID, let property = try await fetchProperty.execute(id: propertyID) {
                original = property
                fill(from: property)
            }
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    func save() async {
        guard let property = makeProperty() else {
            notice = .invalidInput(message: String(localized: "家賃・面積・徒歩分は数字で入力してください", bundle: .module))
            return
        }
        isSaving = true
        defer {
            isSaving = false
        }
        do {
            if isNew {
                _ = try await addProperty.execute(property)
            } else {
                try await updateProperty.execute(property)
            }
            didSave = true
        } catch AddPropertyUseCase.Failure.limitReached(let limit) {
            notice = .limitReached(limit: limit)
        } catch AddPropertyUseCase.Failure.proRequired, UpdatePropertyUseCase.Failure.proRequired {
            notice = .proRequired
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    // MARK: - Private

    private func fill(from property: Property) {
        name = property.name
        rentText = property.rent.map(String.init) ?? ""
        layout = property.layout
        areaText = property.areaSquareMeters.map(NumberInput.text(from:)) ?? ""
        nearestStation = property.nearestStation
        walkMinutesText = property.walkMinutes.map(String.init) ?? ""
        visitedAt = property.visitedAt
        memo = property.memo
        customerID = property.customerID
    }

    private func makeProperty() -> Property? {
        guard let rent = NumberInput.integer(from: rentText),
              let area = NumberInput.decimal(from: areaText),
              let walkMinutes = NumberInput.integer(from: walkMinutesText) else {
            return nil
        }
        return Property(
            id: original?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            rent: rent.value,
            layout: layout.trimmingCharacters(in: .whitespacesAndNewlines),
            areaSquareMeters: area.value,
            nearestStation: nearestStation.trimmingCharacters(in: .whitespacesAndNewlines),
            walkMinutes: walkMinutes.value,
            visitedAt: visitedAt,
            memo: memo,
            photos: original?.photos ?? [],
            measurements: original?.measurements ?? [],
            checkResults: original?.checkResults ?? [],
            customerID: customerID,
            createdAt: original?.createdAt ?? Date()
        )
    }
}
