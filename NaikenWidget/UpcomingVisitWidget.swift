import SwiftUI
import WidgetKit

/// ロック画面・ホーム画面に次の内見予定を出す
struct UpcomingVisitWidget: Widget {
    private static let kind = "UpcomingVisitWidget"

    var body: some WidgetConfiguration {
        return StaticConfiguration(kind: Self.kind, provider: UpcomingVisitProvider()) { entry in
            UpcomingVisitWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("次の内見")
        .description("次の内見予定を表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}
