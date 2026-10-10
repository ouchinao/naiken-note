import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// 画像ファイルを同梱せずその場で作るのは、撮影日時や時差の有無をテストごとに変えるため
enum JPEGFixture {
    enum Failure: Error {
        case drawingFailed
        case encodingFailed
        case unreadable
    }

    static func make(
        width: Int,
        height: Int,
        dateTimeOriginal: String? = nil,
        offset: String? = nil,
        tiffDateTime: String? = nil,
        orientation: CGImagePropertyOrientation? = nil
    ) throws -> Data {
        let image = try solidImage(width: width, height: height)
        let output = NSMutableData()
        let type = UTType.jpeg.identifier as CFString
        guard let destination = CGImageDestinationCreateWithData(output as CFMutableData, type, 1, nil) else {
            throw Failure.encodingFailed
        }
        var exif: [CFString: Any] = [:]
        if let dateTimeOriginal {
            exif[kCGImagePropertyExifDateTimeOriginal] = dateTimeOriginal
        }
        if let offset {
            exif[kCGImagePropertyExifOffsetTimeOriginal] = offset
        }
        var properties: [CFString: Any] = [kCGImagePropertyExifDictionary: exif]
        if let tiffDateTime {
            properties[kCGImagePropertyTIFFDictionary] = [kCGImagePropertyTIFFDateTime: tiffDateTime]
        }
        if let orientation {
            properties[kCGImagePropertyOrientation] = orientation.rawValue
        }
        CGImageDestinationAddImage(destination, image, properties as CFDictionary)
        if !CGImageDestinationFinalize(destination) {
            throw Failure.encodingFailed
        }
        return output as Data
    }

    static func pixelSize(of data: Data) throws -> CGSize {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int else {
            throw Failure.unreadable
        }
        return CGSize(width: width, height: height)
    }

    // MARK: - Private

    private static func solidImage(width: Int, height: Int) throws -> CGImage {
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            throw Failure.drawingFailed
        }
        context.setFillColor(red: 0.2, green: 0.6, blue: 0.5, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        guard let image = context.makeImage() else {
            throw Failure.drawingFailed
        }
        return image
    }
}
