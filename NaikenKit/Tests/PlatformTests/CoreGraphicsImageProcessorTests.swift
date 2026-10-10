import CoreGraphics
import Foundation
import Testing
@testable import Platform

struct CoreGraphicsImageProcessorTests {
    private let processor = CoreGraphicsImageProcessor()

    @Test("4032×3024の写真を長辺2,048pxに縮小する")
    func downsizesLongSideTo2048() async throws {
        let original = try JPEGFixture.make(width: 4_032, height: 3_024)

        let data = try await processor.downsized(original, maxPixelSize: 2_048)

        #expect(try JPEGFixture.pixelSize(of: data) == CGSize(width: 2_048, height: 1_536))
    }

    @Test("サムネイルは長辺320pxにする")
    func makesThumbnailAt320() async throws {
        let original = try JPEGFixture.make(width: 4_032, height: 3_024)

        let data = try await processor.thumbnail(original, maxPixelSize: 320)

        #expect(try JPEGFixture.pixelSize(of: data) == CGSize(width: 320, height: 240))
    }

    @Test("長辺が上限より小さい写真は拡大しない")
    func doesNotUpscaleSmallImage() async throws {
        let original = try JPEGFixture.make(width: 800, height: 600)

        let data = try await processor.downsized(original, maxPixelSize: 2_048)

        #expect(try JPEGFixture.pixelSize(of: data) == CGSize(width: 800, height: 600))
    }

    @Test("EXIFの撮影日時を時差込みで読み取る")
    func readsExifDateWithOffset() throws {
        let original = try JPEGFixture.make(width: 64, height: 64, dateTimeOriginal: "2026:10:01 14:30:00", offset: "+09:00")

        #expect(processor.captureDate(of: original) == Date(timeIntervalSince1970: 1_790_832_600))
    }

    @Test("時差のない撮影日時は端末のタイムゾーンの時刻として読む")
    func readsExifDateWithoutOffsetInCurrentTimeZone() throws {
        let original = try JPEGFixture.make(width: 64, height: 64, dateTimeOriginal: "2026:10:01 14:30:00")
        let expected = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: .current,
            year: 2026,
            month: 10,
            day: 1,
            hour: 14,
            minute: 30
        ).date

        #expect(processor.captureDate(of: original) == expected)
    }

    @Test("EXIFに撮影日時がなければnil")
    func returnsNilWithoutExifDate() throws {
        let original = try JPEGFixture.make(width: 64, height: 64)

        #expect(processor.captureDate(of: original) == nil)
    }
}
