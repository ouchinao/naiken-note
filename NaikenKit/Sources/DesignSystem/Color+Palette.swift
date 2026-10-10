import SwiftUI
import UIKit

extension Color {
    /// アプリのブランドカラー(青緑)
    public static let brand = Color(red: 0.11, green: 0.55, blue: 0.53)
    /// 良い評価
    public static let positive = Color.green
    /// どちらとも言えない評価
    public static let caution = Color.orange
    /// 悪い評価
    public static let negative = Color.red
    /// カードや表のセルの背景
    public static let surface = Color(uiColor: .secondarySystemBackground)
}
