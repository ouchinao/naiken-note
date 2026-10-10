import Foundation
@testable import Domain

// downsized と thumbnail は async let で並行に呼ばれるので、記録はロックで守る
final class ImageProcessorMock: ImageProcessor, @unchecked Sendable {
    private(set) var downsizedSizes: [Int] = []
    private(set) var thumbnailSizes: [Int] = []

    private let lock = NSLock()
    private let stubbedCaptureDate: Date?

    init(captureDate: Date? = nil) {
        stubbedCaptureDate = captureDate
    }

    func downsized(_ data: Data, maxPixelSize: Int) async throws -> Data {
        lock.withLock {
            downsizedSizes.append(maxPixelSize)
        }
        return Data("image-\(maxPixelSize)".utf8)
    }

    func thumbnail(_ data: Data, maxPixelSize: Int) async throws -> Data {
        lock.withLock {
            thumbnailSizes.append(maxPixelSize)
        }
        return Data("thumbnail-\(maxPixelSize)".utf8)
    }

    func captureDate(of data: Data) -> Date? {
        return stubbedCaptureDate
    }
}
