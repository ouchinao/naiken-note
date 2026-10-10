import DesignSystem
import Domain
import SwiftUI

struct MeasurementsTabView: View {
    @Bindable private var viewModel: MeasurementsTabViewModel
    private let property: Property
    @Environment(Router.self) private var router

    init(viewModel: MeasurementsTabViewModel, property: Property) {
        self.viewModel = viewModel
        self.property = property
    }

    var body: some View {
        List {
            Section {
                Button {
                    router.present(.measurementEditor(propertyID: property.id, id: nil))
                } label: {
                    Label("採寸を追加", systemImage: "plus")
                }
            }
            Section {
                if property.measurements.isEmpty {
                    Text("窓やカーテンレール、家具を置く場所の寸法を残しておけます")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                ForEach(property.measurements) { measurement in
                    Button {
                        router.present(.measurementEditor(propertyID: property.id, id: measurement.id))
                    } label: {
                        MeasurementRow(measurement: measurement, photoTag: photoTag(of: measurement))
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in
                    let targets = offsets.map { property.measurements[$0] }
                    Task { await viewModel.delete(targets) }
                }
            }
        }
        .alert("確認", isPresented: $viewModel.isNoticePresented, presenting: viewModel.notice) { _ in
            Button("閉じる", role: .cancel) {}
        } message: { notice in
            switch notice {
            case .failed(let message):
                Text(message)
            }
        }
    }

    // MARK: - Private

    private func photoTag(of measurement: Measurement) -> String? {
        guard let photoID = measurement.photoID else {
            return nil
        }
        return property.photos.first { $0.id == photoID }?.roomTag.title
    }
}

private struct MeasurementRow: View {
    let measurement: Measurement
    let photoTag: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            HStack {
                Text(measurement.label)
                Spacer()
                Text(DisplayFormat.millimeters(measurement.valueMillimeters))
                    .font(.body.monospacedDigit())
                    .bold()
            }
            if !measurement.note.isEmpty {
                Text(measurement.note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let photoTag {
                Label(photoTag, systemImage: "photo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
