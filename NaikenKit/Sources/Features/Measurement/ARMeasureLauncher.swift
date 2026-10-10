import SwiftUI

/// AR採寸の画面を作る。ARKitのセッションを用意できるApp層が中身を与え、ARを使えない端末ではnilにする
public struct ARMeasureLauncher {
    /// 画面を閉じるときに、測った値(ミリ)を渡す。キャンセルならnil
    public typealias Completion = @MainActor (Int?) -> Void

    let makeView: @MainActor (@escaping Completion) -> AnyView

    public init(makeView: @escaping @MainActor (@escaping Completion) -> AnyView) {
        self.makeView = makeView
    }
}
