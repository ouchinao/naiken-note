import Foundation

/// iCloudからの変更通知は短時間に続けて届くので、少し待ってから読み込み直す
enum StoreChangeDebounce {
    static let interval: Duration = .milliseconds(300)
}
