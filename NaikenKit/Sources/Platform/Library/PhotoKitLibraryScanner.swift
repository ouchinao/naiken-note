import CoreLocation
import Domain
import Foundation
import Photos

/// 写真ライブラリから撮影日時で写真を列挙する。読み取りには写真ライブラリの権限が要る
public struct PhotoKitLibraryScanner: PhotoLibraryScanner {
    public enum Failure: Error {
        case assetNotFound
        case imageUnavailable
    }

    public init() {}

    public func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status == .authorized || status == .limited
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

    /// 写真の画像データを縮小してサムネイルにする。UIImage を経由しないので UIKit を使わない
    public func thumbnailData(for id: String, maxPixelSize: Int) async -> Data? {
        guard let data = try? await imageData(for: id) else {
            return nil
        }
        return try? CoreGraphicsImageProcessor.resizedJPEG(from: data, maxPixelSize: maxPixelSize)
    }

    public func imageData(for id: String) async throws -> Data {
        guard let asset = asset(id: id) else {
            throw Failure.assetNotFound
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.isNetworkAccessAllowed = true
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                if let data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: Failure.imageUnavailable)
                }
            }
        }
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
}
