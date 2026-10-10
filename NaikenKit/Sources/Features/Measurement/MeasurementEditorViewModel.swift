import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class MeasurementEditorViewModel {
    enum Notice {
        case invalidInput(message: String)
        case failed(message: String)
    }

    // MARK: - State

    var label = ""
    var valueText = ""
    var note = ""
    var photoID: UUID?
    private(set) var photos: [Photo] = []
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
        return measurementID == nil
    }

    // MARK: - Init

    @ObservationIgnored private var original: Measurement?
    private let propertyID: UUID
    private let measurementID: UUID?
    private let fetchProperty: FetchPropertyUseCase
    private let saveMeasurement: SaveMeasurementUseCase

    public init(
        propertyID: UUID,
        measurementID: UUID?,
        fetchProperty: FetchPropertyUseCase,
        saveMeasurement: SaveMeasurementUseCase
    ) {
        self.propertyID = propertyID
        self.measurementID = measurementID
        self.fetchProperty = fetchProperty
        self.saveMeasurement = saveMeasurement
    }

    // MARK: - Actions

    func load() async {
        do {
            guard let property = try await fetchProperty.execute(id: propertyID) else {
                return
            }
            photos = property.photos
            if let measurement = property.measurements.first(where: { $0.id == measurementID }) {
                original = measurement
                label = measurement.label
                valueText = String(measurement.valueMillimeters)
                note = measurement.note
                photoID = measurement.photoID
            }
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    func save() async {
        guard let parsed = NumberInput.integer(from: valueText), let value = parsed.value else {
            notice = .invalidInput(message: String(localized: "寸法をミリ単位の数字で入力してください", bundle: .module))
            return
        }
        let measurement = Measurement(
            id: original?.id ?? UUID(),
            label: label.trimmingCharacters(in: .whitespacesAndNewlines),
            valueMillimeters: value,
            note: note,
            photoID: photoID,
            createdAt: original?.createdAt ?? Date()
        )
        do {
            try await saveMeasurement.execute(measurement, propertyID: propertyID)
            didSave = true
        } catch SaveMeasurementUseCase.Failure.emptyLabel {
            notice = .invalidInput(message: String(localized: "どこの寸法かを入力してください", bundle: .module))
        } catch SaveMeasurementUseCase.Failure.invalidValue {
            notice = .invalidInput(message: String(localized: "寸法は1mm以上で入力してください", bundle: .module))
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
