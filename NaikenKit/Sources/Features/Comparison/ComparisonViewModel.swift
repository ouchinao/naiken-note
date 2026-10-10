import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class ComparisonViewModel {
    enum Notice: Equatable {
        case locked
        case failed(message: String)
    }

    // MARK: - State

    private(set) var entries: [ComparisonEntry] = []
    private(set) var isLoading = false
    private(set) var isExporting = false
    private(set) var exportedImage: Data?
    private(set) var hasShared = false
    var notice: Notice?

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

    private let propertyIDs: [UUID]
    private let buildComparison: BuildComparisonUseCase
    private let exportComparison: ExportComparisonUseCase

    public init(propertyIDs: [UUID], buildComparison: BuildComparisonUseCase, exportComparison: ExportComparisonUseCase) {
        self.propertyIDs = propertyIDs
        self.buildComparison = buildComparison
        self.exportComparison = exportComparison
    }

    // MARK: - Actions

    func load() async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            entries = try await buildComparison.execute(propertyIDs: propertyIDs)
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    /// 比較表を画像にする。未解錠なら `Notice.locked` を出す
    func export() async {
        isExporting = true
        defer {
            isExporting = false
        }
        do {
            exportedImage = try await exportComparison.execute(entries)
        } catch ExportComparisonUseCase.Failure.locked {
            notice = .locked
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    func recordShare() {
        hasShared = true
    }
}
