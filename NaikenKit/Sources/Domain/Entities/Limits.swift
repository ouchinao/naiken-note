import Foundation

public enum Limits {
    public static let freePropertyCount = 3
    public static let comparisonMinimumCount = 2
    /// 5件以上にしないのは、スマホの横幅では表が読めなくなるため
    public static let comparisonMaximumCount = 4
    /// ウィジェットに出す件数だけを渡さないのは、アプリを開かなくても内見の時刻を過ぎるたびに次の予定へ切り替えられるようにするため
    static let publishedUpcomingVisitCount = 20
}
