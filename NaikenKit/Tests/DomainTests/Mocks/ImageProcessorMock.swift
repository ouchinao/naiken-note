import Foundation
@testable import Domain

// ロックを省かないのは、downsized と thumbnail が async let で並行に呼ばれるため
final class ImageProcessorMock: ImageProcessor, @unchecked Sendable {
    private(set) var downsizedSizes: [Int] = []
    private(set) var thumbnailSizes: [Int] = []

    private let lock = NSLock()
    private let stubbedCaptureDate: Date?

    init(captureDate: Date? = nil) {
        stubbedCaptureDate = captureDate
    }

    func downsized(_: Data, maxPixelSize: Int) async throws -> Data {
        lock.withLock {
            downsizedSizes.append(maxPixelSize)
        }
        return Data("image-\(maxPixelSize)".utf8)
    }

    func thumbnail(_: Data, maxPixelSize: Int) async throws -> Data {
        lock.withLock {
            thumbnailSizes.append(maxPixelSize)
        }
        return Data("thumbnail-\(maxPixelSize)".utf8)
    }

    func captureDate(of _: Data) -> Date? {
        return stubbedCaptureDate
    }
}
