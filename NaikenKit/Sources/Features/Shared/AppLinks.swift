import Foundation

/// アプリ外へのリンク
public enum AppLinks {
    /// 問い合わせ先。LICENSE に書いた窓口と揃える
    public static let contact = URL(string: "https://github.com/ouchinao/naiken-note/issues")
    public static let privacyPolicy = URL(string: "https://github.com/ouchinao/naiken-note/blob/main/PRIVACY.md")
    /// Appleの標準利用規約(EULA)
    public static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
}
