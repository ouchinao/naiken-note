import Foundation

/// 写真ライブラリから内見の写真を選ぶルール
public enum LibraryScanRule {
    /// 内見日時の前後この秒数に撮った写真を候補にする
    public static let timeWindow: TimeInterval = 60 * 60
    /// 内見日時に最も近い写真の撮影地点から、この距離(メートル)以内の写真だけを残す
    public static let radiusMeters = 500.0

    /// 期間内の写真のうち、内見場所から離れた写真を除いて撮影順に並べる。位置情報のない写真は残す
    public static func filter(_ candidates: [LibraryPhotoCandidate], around visitAt: Date) -> [LibraryPhotoCandidate] {
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
