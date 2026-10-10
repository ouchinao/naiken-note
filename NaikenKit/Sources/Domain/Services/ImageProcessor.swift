import Foundation

public protocol ImageProcessor: Sendable {
    func downsized(_ data: Data, maxPixelSize: Int) async throws -> Data
    func thumbnail(_ data: Data, maxPixelSize: Int) async throws -> Data
    func captureDate(of data: Data) -> Date?
}
