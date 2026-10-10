import Foundation

/// 通知のたびに読み込み直さないのは、iCloud からの変更通知が短時間に続けて届くため
enum StoreChangeDebounce {
    static let interval: Duration = .milliseconds(300)
}
