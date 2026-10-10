import Domain
import Foundation

struct ImageProcessorStub: ImageProcessor {
    func downsized(_ data: Data, maxPixelSize _: Int) async throws -> Data {
        return data
    }

    func thumbnail(_ data: Data, maxPixelSize _: Int) async throws -> Data {
        return data
    }

    func captureDate(of _: Data) -> Date? {
        return nil
    }
}
