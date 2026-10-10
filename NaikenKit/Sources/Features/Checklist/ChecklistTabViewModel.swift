import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class ChecklistTabViewModel {
    enum Notice {
        case failed(message: String)
    }

    // MARK: - State

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

    private let saveCheckResult: SaveCheckResultUseCase

    public init(saveCheckResult: SaveCheckResultUseCase) {
        self.saveCheckResult = saveCheckResult
    }

    // MARK: - Actions

    func setRating(_ rating: CheckResult.Rating?, for item: CheckItem, in property: Property) async {
        var result = currentResult(for: item, in: property)
        result.rating = rating
        await save(result, propertyID: property.id)
    }

    func setNote(_ note: String, for item: CheckItem, in property: Property) async {
        var result = currentResult(for: item, in: property)
        if result.note == note {
            return
        }
        result.note = note
        await save(result, propertyID: property.id)
    }

    // MARK: - Private

    private func currentResult(for item: CheckItem, in property: Property) -> CheckResult {
        return property.checkResult(forItemKey: item.id) ?? CheckResult(id: UUID(), itemKey: item.id)
    }

    private func save(_ result: CheckResult, propertyID: UUID) async {
        do {
            try await saveCheckResult.execute(result, propertyID: propertyID)
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
