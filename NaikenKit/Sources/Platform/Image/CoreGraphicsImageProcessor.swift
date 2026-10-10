import Domain
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// `UIImage` に読み込んでから縮小しないのは、元画像をメモリに全展開してしまうため
public struct CoreGraphicsImageProcessor: ImageProcessor {
    private enum Failure: Error {
        case unreadableImage
        case encodingFailed
    }

    public init() {}

    public func downsized(_ data: Data, maxPixelSize: Int) async throws -> Data {
        return try Self.resizedJPEG(from: data, maxPixelSize: maxPixelSize)
    }

    public func thumbnail(_ data: Data, maxPixelSize: Int) async throws -> Data {
        return try Self.resizedJPEG(from: data, maxPixelSize: maxPixelSize)
    }

    public func captureDate(of data: Data) -> Date? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return nil
        }
        return Self.captureDate(from: properties)
    }

    static func captureDate(from properties: [CFString: Any]) -> Date? {
        let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any]
        let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
        guard let text = exif?[kCGImagePropertyExifDateTimeOriginal] as? String ?? tiff?[kCGImagePropertyTIFFDateTime] as? String else {
            return nil
        }
        let offset = exif?[kCGImagePropertyExifOffsetTimeOriginal] as? String
        return ExifDateParser.date(from: text, offset: offset)
    }

    // MARK: - Private

    private static func resizedJPEG(from data: Data, maxPixelSize: Int) throws -> Data {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw Failure.unreadableImage
        }
        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
            throw Failure.unreadableImage
        }
        let output = NSMutableData()
        let type = UTType.jpeg.identifier as CFString
        guard let destination = CGImageDestinationCreateWithData(output as CFMutableData, type, 1, nil) else {
            throw Failure.encodingFailed
        }
        let encodeOptions: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: ImageSpec.jpegQuality]
        CGImageDestinationAddImage(destination, image, encodeOptions as CFDictionary)
        if !CGImageDestinationFinalize(destination) {
            throw Failure.encodingFailed
        }
        return output as Data
    }
}
