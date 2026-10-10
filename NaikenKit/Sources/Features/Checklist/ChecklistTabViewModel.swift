import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class ChecklistTabViewModel {
    enum Notice: Equatable {
        case failed(message: String)
    }

    // MARK: - State

    private(set) var notice: Notice?
    /// 保存した結果を物件の読み直しまで持っておくのは、読み直す前に続けて評価やメモを変えたとき、古い物件から組み立てて先の変更を消さないため
    private var savedResults: [String: CheckResult] = [:]
    /// 入力中のメモを行の View に持たせないのは、行がスクロールで作り直されると入力中の文字が古い値に戻るため
    private var noteDrafts: [String: String] = [:]

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

    func result(for item: CheckItem, in property: Property) -> CheckResult? {
        return savedResults[item.id] ?? property.checkResult(forItemKey: item.id)
    }

    func note(for item: CheckItem, in property: Property) -> String {
        return noteDrafts[item.id] ?? result(for: item, in: property)?.note ?? ""
    }

    func editNote(_ note: String, for item: CheckItem) {
        noteDrafts[item.id] = note
    }

    func commitNote(for item: CheckItem, in property: Property) async {
        guard let draft = noteDrafts.removeValue(forKey: item.id) else {
            return
        }
        var result = currentResult(for: item, in: property)
        if result.note == draft {
            return
        }
        result.note = draft
        await save(result, propertyID: property.id)
    }

    func setRating(_ rating: CheckResult.Rating?, for item: CheckItem, in property: Property) async {
        var result = currentResult(for: item, in: property)
        result.rating = rating
        await save(result, propertyID: property.id)
    }

    func didReload(_ property: Property) {
        savedResults = savedResults.filter { itemKey, saved in
            guard let stored = property.checkResult(forItemKey: itemKey) else {
                return true
            }
            return stored.rating != saved.rating || stored.note != saved.note
        }
    }

    // MARK: - Private

    private func currentResult(for item: CheckItem, in property: Property) -> CheckResult {
        return result(for: item, in: property) ?? CheckResult(id: UUID(), itemKey: item.id)
    }

    private func save(_ result: CheckResult, propertyID: UUID) async {
        let previous = savedResults[result.itemKey]
        savedResults[result.itemKey] = result
        do {
            try await saveCheckResult.execute(result, propertyID: propertyID)
        } catch {
            savedResults[result.itemKey] = previous
            notice = .failed(message: error.localizedDescription)
        }
    }
}
