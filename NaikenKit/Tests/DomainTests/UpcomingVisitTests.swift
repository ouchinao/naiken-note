import Foundation
import Testing
@testable import Domain

struct UpcomingVisitTests {
    @Test("アプリが書き出した内見予定を、ウィジェットがそのまま読み戻せる")
    func roundTripsThroughSharedStorage() throws {
        let visits = [
            UpcomingVisit(
                propertyID: UUID(),
                name: "A棟201",
                visitAt: Date(timeIntervalSince1970: 1_800_000_000),
                nearestStation: "学芸大学"
            ),
        ]

        let decoded = try UpcomingVisit.decode(UpcomingVisit.encode(visits))

        #expect(decoded == visits)
    }
}
