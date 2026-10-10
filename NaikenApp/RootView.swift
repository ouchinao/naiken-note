import Features
import SwiftUI

struct RootView: View {
    @Environment(Router.self) private var router

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            PropertyListView(viewModel: container.makePropertyListViewModel())
                .navigationDestination(for: Router.Route.self) { route in
                    container.makeView(for: route)
                }
        }
        .sheet(item: $router.sheet) { sheet in
            container.makeView(for: sheet)
        }
        .fullScreenCover(item: $router.fullScreen) { screen in
            container.makeView(for: screen)
        }
        .task { await container.keepUpcomingVisitsUpdated() }
    }
}
