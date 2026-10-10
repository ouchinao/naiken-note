import Foundation

enum RepositoryError: Error {
    /// 紐づけ先の物件が見つからない。別の端末で削除された直後などに起きる
    case propertyNotFound
}
