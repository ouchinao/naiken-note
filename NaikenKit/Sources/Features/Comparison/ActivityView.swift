import SwiftUI
import UIKit

/// `ShareLink` を使わないのは、共有を取りやめたかどうかを受け取れず、送っていなくてもレビューを頼んでしまうため
struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    let onComplete: @MainActor @Sendable (Bool) -> Void

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        let onComplete = onComplete
        controller.completionWithItemsHandler = { _, completed, _, _ in
            Task { @MainActor in
                onComplete(completed)
            }
        }
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
