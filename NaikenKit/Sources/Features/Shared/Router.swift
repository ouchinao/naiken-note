import Foundation
import Observation

/// 遷移先を View ではなく名前で持つのは、Features が遷移先の画面の依存を組み立てずに済むようにするため
@MainActor
@Observable
public final class Router {
    public enum Route: Hashable {
        case propertyDetail(id: UUID)
        case comparison(ids: [UUID])
        case settings
        case customers
    }

    public enum Sheet: Identifiable {
        case propertyEditor(id: UUID?)
        case measurementEditor(propertyID: UUID, id: UUID?)
        case libraryImport(propertyID: UUID)
        case paywall

        public var id: String {
            switch self {
            case .propertyEditor(let id):
                return "propertyEditor-\(id?.uuidString ?? "new")"
            case .measurementEditor(let propertyID, let id):
                return "measurementEditor-\(propertyID)-\(id?.uuidString ?? "new")"
            case .libraryImport(let propertyID):
                return "libraryImport-\(propertyID)"
            case .paywall:
                return "paywall"
            }
        }
    }

    public enum FullScreen: Identifiable {
        case camera(propertyID: UUID)
        case photo(id: UUID)

        public var id: String {
            switch self {
            case .camera(let propertyID):
                return "camera-\(propertyID)"
            case .photo(let id):
                return "photo-\(id)"
            }
        }
    }

    public var path: [Route] = []
    public var sheet: Sheet?
    /// 開いているシートを置き換えないのは、物件の編集中に Paywall を開いても入力を捨てないため
    public var stackedSheet: Sheet?
    public var fullScreen: FullScreen?

    public init() {}

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func present(_ sheet: Sheet) {
        if self.sheet == nil {
            self.sheet = sheet
        } else {
            stackedSheet = sheet
        }
    }

    func presentFullScreen(_ screen: FullScreen) {
        fullScreen = screen
    }

    func dismiss() {
        if stackedSheet != nil {
            stackedSheet = nil
            return
        }
        sheet = nil
        fullScreen = nil
    }
}
