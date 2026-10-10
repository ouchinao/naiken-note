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
    }

    public enum Sheet: Identifiable {
        case propertyEditor(id: UUID?)
        case measurementEditor(propertyID: UUID, id: UUID?)
        case paywall

        public var id: String {
            switch self {
            case .propertyEditor(let id):
                return "propertyEditor-\(id?.uuidString ?? "new")"
            case .measurementEditor(let propertyID, let id):
                return "measurementEditor-\(propertyID)-\(id?.uuidString ?? "new")"
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
    public var fullScreen: FullScreen?

    public init() {}

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func present(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func presentFullScreen(_ screen: FullScreen) {
        fullScreen = screen
    }

    func dismiss() {
        sheet = nil
        fullScreen = nil
    }
}
