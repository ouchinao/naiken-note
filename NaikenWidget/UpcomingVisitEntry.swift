import Domain
import Foundation
import WidgetKit

struct UpcomingVisitEntry: TimelineEntry {
    let date: Date
    let visits: [UpcomingVisit]

    static var placeholder: UpcomingVisitEntry {
        let visit = UpcomingVisit(
            propertyID: UUID(),
            name: String(localized: "A棟201"),
            visitAt: Date().addingTimeInterval(60 * 60),
            nearestStation: String(localized: "学芸大学"),
            walkMinutes: 6
        )
        return UpcomingVisitEntry(date: Date(), visits: [visit])
    }
}
