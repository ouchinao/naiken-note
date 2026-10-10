import Foundation

public enum LibraryScanRule {
    public static let timeWindow: TimeInterval = 60 * 60
    /// 物件の住所から位置を引かず、内見日時に最も近い写真の撮影地点を内見場所とみなすのは、住所の入力もジオコーディングの通信も要らないようにするため
    static let radiusMeters = 500.0

    static func filter(_ candidates: [LibraryPhotoCandidate], around visitAt: Date) -> [LibraryPhotoCandidate] {
        let inWindow = candidates.filter { abs($0.takenAt.timeIntervalSince(visitAt)) <= timeWindow }
        let sorted = inWindow.sorted { $0.takenAt < $1.takenAt }
        guard let anchor = anchorCoordinate(of: inWindow, around: visitAt) else {
            return sorted
        }
        return sorted.filter { candidate in
            guard let coordinate = candidate.coordinate else {
                return true
            }
            return coordinate.distance(to: anchor) <= radiusMeters
        }
    }

    // MARK: - Private

    private static func anchorCoordinate(of candidates: [LibraryPhotoCandidate], around visitAt: Date) -> GeoCoordinate? {
        let located = candidates.filter { $0.coordinate != nil }
        let closest = located.min { lhs, rhs in
            return abs(lhs.takenAt.timeIntervalSince(visitAt)) < abs(rhs.takenAt.timeIntervalSince(visitAt))
        }
        return closest?.coordinate
    }
}
