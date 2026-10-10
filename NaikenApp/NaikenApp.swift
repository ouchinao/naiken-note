import DesignSystem
import Features
import SwiftUI

@main
struct NaikenApp: App {
    private let container: AppContainer

    init() {
        do {
            container = try AppContainer()
        } catch {
            fatalError("ModelContainer の生成に失敗: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .environment(container.router)
                .environment(container.entitlementStore)
                .tint(Color.brand)
        }
    }
}
