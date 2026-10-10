import Domain
import SwiftUI
import WidgetKit

struct UpcomingVisitWidgetView: View {
    private static let mediumVisitCount = 3

    let entry: UpcomingVisitEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryInline:
            inline
        case .accessoryRectangular:
            rectangular
        case .systemMedium:
            list(limit: Self.mediumVisitCount)
        default:
            list(limit: 1)
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var inline: some View {
        if let visit = entry.visits.first {
            Text("次の内見 \(visit.visitAt.formatted(date: .omitted, time: .shortened)) \(visit.name)")
        } else {
            Text("内見の予定はありません")
        }
    }

    @ViewBuilder
    private var rectangular: some View {
        if let visit = entry.visits.first {
            VStack(alignment: .leading) {
                Text("次の内見")
                    .font(.caption)
                Text(visit.name)
                    .font(.headline)
                    .widgetAccentable()
                Text(visit.visitAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("内見の予定はありません")
                .font(.caption)
        }
    }

    private func list(limit: Int) -> some View {
        return VStack(alignment: .leading, spacing: 6) {
            Label("次の内見", systemImage: "house")
                .font(.caption)
                .foregroundStyle(.secondary)
            if entry.visits.isEmpty {
                Text("内見の予定はありません")
                    .font(.subheadline)
            }
            ForEach(entry.visits.prefix(limit)) { visit in
                VisitRow(visit: visit)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct VisitRow: View {
    let visit: UpcomingVisit

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(visit.name)
                .font(.headline)
                .lineLimit(1)
            Text(visit.visitAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
            if !visit.nearestStation.isEmpty {
                Text(visit.nearestStation)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
