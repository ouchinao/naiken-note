import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class MeasurementsTabViewModel {
    enum Notice {
        case failed(message: String)
    }

    // MARK: - State

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

    private let deleteMeasurement: DeleteMeasurementUseCase

    public init(deleteMeasurement: DeleteMeasurementUseCase) {
        self.deleteMeasurement = deleteMeasurement
    }

    // MARK: - Actions

    func delete(_ measurements: [Measurement]) async {
        do {
            for measurement in measurements {
                try await deleteMeasurement.execute(id: measurement.id)
            }
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
