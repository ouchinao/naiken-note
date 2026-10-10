import Foundation

public enum ProductID {
    public static let unlock = "com.example.naikennote.unlock"
    public static let proMonthly = "com.example.naikennote.pro.monthly"
    public static let all = [unlock, proMonthly]
    /// Paywallで売る商品。並びは表示順
    public static let onSale = [unlock, proMonthly]
}
