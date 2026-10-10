import Foundation

public enum Limits {
    public static let freePropertyCount = 3
    public static let comparisonMinimumCount = 2
    /// 5件以上にしないのは、スマホの横幅では表が読めなくなるため
    public static let comparisonMaximumCount = 4
}
