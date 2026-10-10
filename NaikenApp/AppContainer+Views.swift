import Features
import SwiftUI

/// どの画面を作るかを知っているのはApp層だけ
extension AppContainer {
    @ViewBuilder
    func makeView(for route: Router.Route) -> some View {
        switch route {
        case .propertyDetail(let id):
            PropertyDetailView(
                viewModel: makePropertyDetailViewModel(propertyID: id),
                photosViewModel: makePhotosTabViewModel(),
                measurementsViewModel: makeMeasurementsTabViewModel(),
                checklistViewModel: makeChecklistTabViewModel()
            )
        case .comparison(let ids):
            ComparisonView(viewModel: makeComparisonViewModel(propertyIDs: ids))
        case .settings:
            SettingsView(viewModel: makeSettingsViewModel())
        case .customers:
            CustomersView(viewModel: makeCustomersViewModel())
        }
    }

    @ViewBuilder
    func makeView(for sheet: Router.Sheet) -> some View {
        switch sheet {
        case .propertyEditor(let id):
            PropertyEditorView(viewModel: makePropertyEditorViewModel(propertyID: id))
        case .measurementEditor(let propertyID, let id):
            MeasurementEditorView(
                viewModel: makeMeasurementEditorViewModel(propertyID: propertyID, measurementID: id),
                arMeasure: makeARMeasureLauncher()
            )
        case .libraryImport(let propertyID):
            LibraryImportView(viewModel: makeLibraryImportViewModel(propertyID: propertyID))
        case .paywall:
            PaywallView(viewModel: makePaywallViewModel())
        }
    }

    @ViewBuilder
    func makeView(for screen: Router.FullScreen) -> some View {
        switch screen {
        case .camera(let propertyID):
            CameraScreen(viewModel: makeCameraCaptureViewModel(propertyID: propertyID))
        case .photo(let id):
            PhotoViewerView(viewModel: makePhotoViewerViewModel(photoID: id))
        }
    }
}
