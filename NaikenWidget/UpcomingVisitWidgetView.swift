import DesignSystem
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
            list {
                ForEach(entry.visits.prefix(Self.mediumVisitCount)) { visit in
                    CompactVisitRow(visit: visit, now: entry.date)
                }
            }
        default:
            list {
                if let visit = entry.visits.first {
                    VisitRow(visit: visit)
                }
            }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var inline: some View {
        if let visit = entry.visits.first {
            Text("次の内見 \(VisitTime.text(for: visit.visitAt, now: entry.date)) \(visit.name)")
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

    private func list<Rows: View>(@ViewBuilder rows: () -> Rows) -> some View {
        return VStack(alignment: .leading, spacing: Spacing.xSmall) {
            Label("次の内見", systemImage: "house")
                .font(.caption)
                .foregroundStyle(.secondary)
            if entry.visits.isEmpty {
                Text("内見の予定はありません")
                    .font(.subheadline)
            }
            rows()
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 日付を省いて時刻だけにしないのは、次の内見が明日以降でも今日の予定に見えてしまうため
private enum VisitTime {
    static func text(for date: Date, now: Date) -> String {
        if Calendar.current.isDate(date, inSameDayAs: now) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return date.formatted(.dateTime.month().day().hour().minute())
    }
}

private struct VisitRow: View {
    let visit: UpcomingVisit

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
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

/// 中サイズで1件を複数行にしないのは、3件並べると高さが足りず、最後の予定が切れるため
private struct CompactVisitRow: View {
    let visit: UpcomingVisit
    let now: Date

    var body: some View {
        HStack(spacing: Spacing.small) {
            Text(VisitTime.text(for: visit.visitAt, now: now))
                .font(.caption.monospacedDigit())
            Text(visit.name)
                .font(.subheadline)
                .bold()
                .lineLimit(1)
            if !visit.nearestStation.isEmpty {
                Text(visit.nearestStation)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
