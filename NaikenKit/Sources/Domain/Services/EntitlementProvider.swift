import Foundation

public protocol EntitlementProvider: Sendable {
    /// 同期で読めるプロパティにしないのは、起動直後に購入状態を読み終える前の値で上限や書き出しを判定させないため
    func currentEntitlement() async -> Entitlement
}
