import Foundation

/// 業務ルール上の上限値
public enum Limits {
    /// 無料版で登録できる物件の数
    public static let freePropertyCount = 3
    /// 比較表に並べられる物件の最小数
    public static let comparisonMinimumCount = 2
    /// 比較表に並べられる物件の最大数。スマホの横幅で読める上限
    public static let comparisonMaximumCount = 4
    /// ウィジェットに出す内見予定の数
    public static let upcomingVisitCount = 3
}
