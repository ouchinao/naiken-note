import Foundation

public enum ProductID {
    public static let unlock = "com.example.naikennote.unlock"
    public static let proMonthly = "com.example.naikennote.pro.monthly"
    public static let all = [unlock, proMonthly]
    /// StoreKit から取得する時点で絞らずここで決めるのは、何を売るかを UseCase のテストで確かめられるようにするため
    static let onSale = [unlock]
}
