import CoreLocation
import Domain
import Foundation
import Photos

public struct PhotoKitLibraryScanner: PhotoLibraryScanner {
    private enum Failure: Error {
        case assetNotFound
        case imageUnavailable
    }

    public init() {}

    public func requestAccess() async -> PhotoLibraryAccess {
        switch await PHPhotoLibrary.requestAuthorization(for: .readWrite) {
        case .authorized:
            return .full
        case .limited:
            return .limited
        case .notDetermined, .restricted, .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }

    public func candidates(takenFrom start: Date, to end: Date) async throws -> [LibraryPhotoCandidate] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "mediaType == %d AND creationDate >= %@ AND creationDate <= %@",
            PHAssetMediaType.image.rawValue,
            start as NSDate,
            end as NSDate
        )
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        var candidates: [LibraryPhotoCandidate] = []
        PHAsset.fetchAssets(with: options).enumerateObjects { asset, _, _ in
            if let takenAt = asset.creationDate {
                candidates.append(LibraryPhotoCandidate(id: asset.localIdentifier, takenAt: takenAt, coordinate: coordinate(of: asset)))
            }
        }
        return candidates
    }

    /// PHImageManager から UIImage で受け取らないのは、Platform に UIKit を持ち込まないため。
    /// 通信を許さないのは、候補を見せるだけのために iCloud から原寸の写真を何枚も落とさないため
    public func thumbnailData(for id: String, maxPixelSize: Int) async -> Data? {
        guard let asset = asset(id: id),
              let data = try? await requestData(for: asset, allowsNetworkAccess: false) else {
            return nil
        }
        return try? CoreGraphicsImageProcessor.resizedJPEG(from: data, maxPixelSize: maxPixelSize)
    }

    public func imageData(for id: String) async throws -> Data {
        guard let asset = asset(id: id) else {
            throw Failure.assetNotFound
        }
        return try await requestData(for: asset, allowsNetworkAccess: true)
    }

    // MARK: - Private

    private func asset(id: String) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
    }

    private func coordinate(of asset: PHAsset) -> GeoCoordinate? {
        guard let location = asset.location else {
            return nil
        }
        return GeoCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    /// 呼び出し元の Task が取り消されても要求を残さないのは、画面を閉じたあとも写真の読み込みやダウンロードを続けないため
    private func requestData(for asset: PHAsset, allowsNetworkAccess: Bool) async throws -> Data {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.isNetworkAccessAllowed = allowsNetworkAccess
        let request = ImageRequest()
        return try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                let requestID = PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                    if let data {
                        continuation.resume(returning: data)
                    } else {
                        continuation.resume(throwing: Failure.imageUnavailable)
                    }
                }
                request.start(requestID)
            }
        } onCancel: {
            request.cancel()
        }
    }
}

// ロックを省かないのは、要求の開始と取り消しが別のスレッドから届くので、@unchecked Sendable で外したコンパイラの検査の代わりが要るため
private final class ImageRequest: @unchecked Sendable {
    private let lock = NSLock()
    private var requestID: PHImageRequestID?
    private var isCancelled = false

    func start(_ id: PHImageRequestID) {
        let shouldCancel = lock.withLock {
            requestID = id
            return isCancelled
        }
        if shouldCancel {
            PHImageManager.default().cancelImageRequest(id)
        }
    }

    func cancel() {
        let id = lock.withLock {
            isCancelled = true
            return requestID
        }
        if let id {
            PHImageManager.default().cancelImageRequest(id)
        }
    }
}
