import Data
import Domain
import Features
import Foundation
import Platform
import SwiftUI

/// 依存の組み立てをすべてここに集める。Data層とPlatform層の具象型を知っているのはこの型だけ
@MainActor
final class AppContainer {
    let router = Router()
    let entitlementStore: EntitlementStore

    private let repositories: SwiftDataRepositories
    private let storeChanges: any StoreChangeObserving = StoreChangeObserver()
    private let purchaseService: any PurchaseService
    private let imageProcessor: any ImageProcessor = CoreGraphicsImageProcessor()
    private let libraryScanner: any PhotoLibraryScanner = PhotoKitLibraryScanner()
    private let upcomingVisitPublisher: any UpcomingVisitPublishing = WidgetUpcomingVisitPublisher()
    private let cloudAccountStatus: any CloudAccountStatusProviding = UbiquityCloudAccountStatusProvider()

    init() throws {
        let modelContainer = try ModelContainerFactory.make()
        repositories = SwiftDataRepositories(modelContainer: modelContainer)
        let purchaseService = StoreKitPurchaseService()
        self.purchaseService = purchaseService
        entitlementStore = EntitlementStore(purchaseService: purchaseService)
    }

    // MARK: - View models

    func makePropertyListViewModel() -> PropertyListViewModel {
        return PropertyListViewModel(
            fetchProperties: FetchPropertiesUseCase(repository: repositories.properties),
            addProperty: addProperty,
            loadPhotoImage: loadPhotoImage,
            storeChanges: storeChanges
        )
    }

    func makePropertyEditorViewModel(propertyID: UUID?) -> PropertyEditorViewModel {
        return PropertyEditorViewModel(
            propertyID: propertyID,
            fetchProperty: fetchProperty,
            addProperty: addProperty,
            updateProperty: UpdatePropertyUseCase(repository: repositories.properties)
        )
    }

    func makePropertyDetailViewModel(propertyID: UUID) -> PropertyDetailViewModel {
        return PropertyDetailViewModel(
            propertyID: propertyID,
            fetchProperty: fetchProperty,
            deleteProperty: DeletePropertyUseCase(repository: repositories.properties),
            storeChanges: storeChanges
        )
    }

    func makePhotosTabViewModel() -> PhotosTabViewModel {
        return PhotosTabViewModel(
            addPhoto: addPhoto,
            updatePhoto: UpdatePhotoUseCase(repository: repositories.photos),
            deletePhoto: DeletePhotoUseCase(repository: repositories.photos),
            setRepresentativePhoto: SetRepresentativePhotoUseCase(repository: repositories.photos),
            loadPhotoImage: loadPhotoImage
        )
    }

    func makeMeasurementsTabViewModel() -> MeasurementsTabViewModel {
        return MeasurementsTabViewModel(deleteMeasurement: DeleteMeasurementUseCase(repository: repositories.measurements))
    }

    func makeChecklistTabViewModel() -> ChecklistTabViewModel {
        return ChecklistTabViewModel(saveCheckResult: SaveCheckResultUseCase(repository: repositories.checkResults))
    }

    func makeMeasurementEditorViewModel(propertyID: UUID, measurementID: UUID?) -> MeasurementEditorViewModel {
        return MeasurementEditorViewModel(
            propertyID: propertyID,
            measurementID: measurementID,
            fetchProperty: fetchProperty,
            saveMeasurement: SaveMeasurementUseCase(repository: repositories.measurements)
        )
    }

    func makeCameraCaptureViewModel(propertyID: UUID) -> CameraCaptureViewModel {
        return CameraCaptureViewModel(propertyID: propertyID, addPhoto: addPhoto)
    }

    func makePhotoViewerViewModel(photoID: UUID) -> PhotoViewerViewModel {
        return PhotoViewerViewModel(photoID: photoID, loadPhotoImage: loadPhotoImage)
    }

    func makeLibraryImportViewModel(propertyID: UUID) -> LibraryImportViewModel {
        return LibraryImportViewModel(
            propertyID: propertyID,
            fetchProperty: fetchProperty,
            scanLibrary: ScanLibraryPhotosUseCase(scanner: libraryScanner),
            importLibrary: ImportLibraryPhotosUseCase(scanner: libraryScanner, addPhoto: addPhoto),
            loadThumbnail: LoadLibraryThumbnailUseCase(scanner: libraryScanner)
        )
    }

    func makeComparisonViewModel(propertyIDs: [UUID]) -> ComparisonViewModel {
        return ComparisonViewModel(
            propertyIDs: propertyIDs,
            buildComparison: BuildComparisonUseCase(
                propertyRepository: repositories.properties,
                photoRepository: repositories.photos
            ),
            exportComparison: ExportComparisonUseCase(
                entitlement: entitlementStore,
                exporter: ImageRendererComparisonExporter()
            )
        )
    }

    func makePaywallViewModel() -> PaywallViewModel {
        return PaywallViewModel(
            loadProducts: LoadProductsUseCase(service: purchaseService),
            purchaseProduct: PurchaseProductUseCase(service: purchaseService),
            restorePurchases: restorePurchases,
            entitlementStore: entitlementStore
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(
            fetchCloudSyncStatus: FetchCloudSyncStatusUseCase(provider: cloudAccountStatus),
            restorePurchases: restorePurchases,
            entitlementStore: entitlementStore
        )
    }

    /// ARを使えない端末ではnilを返し、採寸画面にARのボタンを出さない
    func makeARMeasureLauncher() -> ARMeasureLauncher? {
        if !ARMeasureSession.isSupported {
            return nil
        }
        return ARMeasureLauncher { onFinish in
            let session = ARMeasureSession()
            let view = ARMeasureView(
                viewModel: ARMeasureViewModel(measuring: session),
                session: session.session,
                onFinish: onFinish
            )
            return AnyView(view)
        }
    }

    // MARK: - Widget

    /// 起動時とストアが変わるたびに、次の内見予定をウィジェットに渡す
    func keepUpcomingVisitsUpdated() async {
        let refresh = RefreshUpcomingVisitsUseCase(repository: repositories.properties, publisher: upcomingVisitPublisher)
        try? await refresh.execute()
        for await _ in storeChanges.changes {
            try? await refresh.execute()
        }
    }

    // MARK: - Private

    private var fetchProperty: FetchPropertyUseCase {
        return FetchPropertyUseCase(repository: repositories.properties)
    }

    private var addProperty: AddPropertyUseCase {
        return AddPropertyUseCase(repository: repositories.properties, entitlement: entitlementStore)
    }

    private var addPhoto: AddPhotoUseCase {
        return AddPhotoUseCase(repository: repositories.photos, processor: imageProcessor)
    }

    private var loadPhotoImage: LoadPhotoImageUseCase {
        return LoadPhotoImageUseCase(repository: repositories.photos)
    }

    private var restorePurchases: RestorePurchasesUseCase {
        return RestorePurchasesUseCase(service: purchaseService)
    }
}
