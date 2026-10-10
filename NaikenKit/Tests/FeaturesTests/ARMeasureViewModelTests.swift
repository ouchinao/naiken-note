import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct ARMeasureViewModelTests {
    private let viewSize = CGSize(width: 400, height: 800)

    @Test("タップした位置をビューの大きさで割り、0〜1にして渡す")
    func normalizesTappedPoint() {
        let measuring = ARMeasuringStub()
        let viewModel = ARMeasureViewModel(measuring: measuring)

        viewModel.placePoint(at: CGPoint(x: 100, y: 400), in: viewSize)

        #expect(measuring.receivedPoints == [CGPoint(x: 0.25, y: 0.5)])
    }

    @Test("2点置くと距離を出す")
    func showsDistanceAfterTwoPoints() {
        let viewModel = ARMeasureViewModel(measuring: ARMeasuringStub(distance: 1_690))

        viewModel.placePoint(at: CGPoint(x: 40, y: 400), in: viewSize)
        viewModel.placePoint(at: CGPoint(x: 360, y: 400), in: viewSize)

        #expect(viewModel.placedPointCount == 2 && viewModel.distanceMillimeters == 1_690)
    }

    @Test("3点目を置くと最初からやり直す")
    func thirdPointStartsOver() {
        let viewModel = ARMeasureViewModel(measuring: ARMeasuringStub())

        for pointX in [40.0, 360.0, 200.0] {
            viewModel.placePoint(at: CGPoint(x: pointX, y: 400), in: viewSize)
        }

        #expect(viewModel.markers == [CGPoint(x: 200, y: 400)] && viewModel.distanceMillimeters == nil)
    }

    @Test("面が見つからなければ点を置かずに知らせる")
    func reportsMissingSurface() {
        let viewModel = ARMeasureViewModel(measuring: ARMeasuringStub(isSurfaceFound: false))

        viewModel.placePoint(at: CGPoint(x: 40, y: 400), in: viewSize)

        #expect(viewModel.isSurfaceMissing && viewModel.markers.isEmpty)
    }

    @Test("大きさが0のビューでは点を置かない")
    func ignoresEmptyView() {
        let measuring = ARMeasuringStub()
        let viewModel = ARMeasureViewModel(measuring: measuring)

        viewModel.placePoint(at: CGPoint(x: 40, y: 400), in: .zero)

        #expect(measuring.receivedPoints.isEmpty && viewModel.markers.isEmpty)
    }

    @Test("やり直すと点と距離を消す")
    func resetClearsMeasurement() {
        let viewModel = ARMeasureViewModel(measuring: ARMeasuringStub())
        viewModel.placePoint(at: CGPoint(x: 40, y: 400), in: viewSize)
        viewModel.placePoint(at: CGPoint(x: 360, y: 400), in: viewSize)

        viewModel.reset()

        #expect(viewModel.markers.isEmpty && viewModel.distanceMillimeters == nil)
    }
}
