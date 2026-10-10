import Foundation

enum RepositoryError: Error {
    /// クラッシュさせずにエラーにするのは、別の端末で物件が消された直後に起こりうるため
    case propertyNotFound
}
