import Foundation

/// 項目を永続化しないのは、アプリの更新で項目を直したときに端末ごとの保存データを書き換えずに済ませるため
public struct CheckItem: Identifiable, Hashable, Sendable {
    public enum Category: String, CaseIterable, Sendable {
        case environment
        case water
        case interior
        case storage
        case common
    }

    public let id: String
    public let title: String
    public let category: Category
}
