import ARKit
import DesignSystem
import SwiftUI

/// ARで2点間の距離を測る画面。セッションの開始やraycastは Platform層の ARMeasureSession が担う
public struct ARMeasureView: View {
    private static let markerSize: CGFloat = 14
    private static let lineWidth: CGFloat = 3

    @State private var viewModel: ARMeasureViewModel
    @State private var session: ARSession
    private let onFinish: ARMeasureLauncher.Completion

    public init(viewModel: ARMeasureViewModel, session: ARSession, onFinish: @escaping ARMeasureLauncher.Completion) {
        _viewModel = State(initialValue: viewModel)
        _session = State(initialValue: session)
        self.onFinish = onFinish
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                ARCameraView(session: session)
                markerLayer
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                viewModel.placePoint(at: location, in: proxy.size)
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .top) { guide }
        .overlay(alignment: .bottom) { controls }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    // MARK: - Private

    private var markerLayer: some View {
        ZStack {
            if viewModel.markers.count == 2 {
                Path { path in
                    path.move(to: viewModel.markers[0])
                    path.addLine(to: viewModel.markers[1])
                }
                .stroke(Color.brand, lineWidth: Self.lineWidth)
            }
            ForEach(viewModel.markers.indices, id: \.self) { index in
                Circle()
                    .fill(Color.brand)
                    .frame(width: Self.markerSize, height: Self.markerSize)
                    .position(viewModel.markers[index])
            }
        }
        .allowsHitTesting(false)
    }

    private var guide: some View {
        VStack(spacing: Spacing.xSmall) {
            if let distance = viewModel.distanceMillimeters {
                Text(DisplayFormat.millimeters(distance))
                    .font(.largeTitle.monospacedDigit())
                    .bold()
            } else {
                Text(guideMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            if !viewModel.isLiDARAvailable {
                Text("LiDARのない機種では誤差が大きくなります。保存前に手で直せます")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.medium))
        .padding()
    }

    private var guideMessage: LocalizedStringKey {
        if viewModel.isSurfaceMissing {
            return "面が見つかりません。カメラを少し動かしてから試してください"
        }
        if viewModel.placedPointCount == 0 {
            return "測りたい場所の端をタップしてください"
        }
        return "反対側の端をタップしてください"
    }

    private var controls: some View {
        HStack(spacing: Spacing.medium) {
            Button("キャンセル") { onFinish(nil) }
            Button("やり直す") { viewModel.reset() }
            Button("この値を使う") { onFinish(viewModel.distanceMillimeters) }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.distanceMillimeters == nil)
        }
        .buttonStyle(.bordered)
        .padding()
        .background(.regularMaterial, in: Capsule())
        .padding()
    }
}
