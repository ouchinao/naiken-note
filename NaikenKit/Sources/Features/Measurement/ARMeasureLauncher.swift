import SwiftUI

/// 採寸画面が AR の画面を直接作らないのは、Features から Platform の ARMeasureSession を参照できないため
public struct ARMeasureLauncher {
    public typealias Completion = @MainActor (Int?) -> Void

    let makeView: @MainActor (@escaping Completion) -> AnyView

    public init(makeView: @escaping @MainActor (@escaping Completion) -> AnyView) {
        self.makeView = makeView
    }
}
