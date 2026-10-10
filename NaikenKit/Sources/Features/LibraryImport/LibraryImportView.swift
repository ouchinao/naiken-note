import DesignSystem
import Domain
import SwiftUI
import UIKit

public struct LibraryImportView: View {
    private static let cellMinimumWidth: CGFloat = 100

    @State private var viewModel: LibraryImportViewModel
    @Environment(Router.self) private var router
    @Environment(\.openURL) private var openURL

    public init(viewModel: LibraryImportViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("写真を自動で探す")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("キャンセル") { router.dismiss() }
                    }
                }
                .safeAreaInset(edge: .bottom) { importButton }
        }
        .task { await viewModel.load() }
        .onChange(of: viewModel.didImport) { _, didImport in
            if didImport {
                router.dismiss()
            }
        }
        .alert("確認", isPresented: $viewModel.isNoticePresented, presenting: viewModel.notice) { _ in
            Button("閉じる", role: .cancel) {}
        } message: { notice in
            switch notice {
            case .partiallyFailed(let count):
                Text("\(count)枚を取り込めませんでした。iCloud にしかない写真は、通信できる場所でもう一度取り込んでください")
            case .failed(let message):
                Text(message)
            }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .loading:
            ProgressView("写真を探しています…")
        case .notAuthorized:
            ContentUnavailableView {
                Label("写真へのアクセスが必要です", systemImage: "lock")
            } description: {
                Text("内見の前後に撮った写真を探すため、設定アプリで写真へのアクセスを許可してください")
            } actions: {
                Button("設定を開く") { openSettings() }
            }
        case .empty:
            ContentUnavailableView {
                Label("写真が見つかりません", systemImage: "photo.on.rectangle")
            } description: {
                Text("内見日時の前後\(LibraryScanRule.timeWindowHours)時間に撮った写真はありませんでした")
            } actions: {
                if viewModel.isAccessLimited {
                    limitedAccessNote
                }
            }
        case .ready:
            VStack(spacing: 0) {
                if viewModel.isAccessLimited {
                    limitedAccessNote
                        .padding(.horizontal)
                }
                candidateGrid
            }
        }
    }

    private var limitedAccessNote: some View {
        VStack(spacing: Spacing.xSmall) {
            Text("写真へのアクセスが一部の写真に限られているため、探せる写真も限られます")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("設定でアクセスを広げる") { openSettings() }
                .font(.footnote)
        }
    }

    private var candidateGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Self.cellMinimumWidth), spacing: Spacing.small)], spacing: Spacing.small) {
                ForEach(viewModel.candidates) { candidate in
                    Button {
                        viewModel.toggle(candidate)
                    } label: {
                        CandidateCell(
                            thumbnail: viewModel.thumbnails[candidate.id],
                            takenAt: candidate.takenAt,
                            isSelected: viewModel.isSelected(candidate)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var importButton: some View {
        if viewModel.phase == .ready {
            Button("\(viewModel.selectedIDs.count)枚を取り込む") {
                Task { await viewModel.importSelected() }
            }
            .buttonStyle(.primary)
            .disabled(viewModel.selectedIDs.isEmpty || viewModel.isImporting)
            .padding()
            .background(.bar)
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

private struct CandidateCell: View {
    private static let unselectedOpacity = 0.6

    let thumbnail: Data?
    let takenAt: Date
    let isSelected: Bool

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                ThumbnailView(data: thumbnail)
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            .overlay(alignment: .topTrailing) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.brand : Color.white)
                    .padding(Spacing.xSmall)
            }
            .opacity(isSelected ? 1 : Self.unselectedOpacity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("\(takenAt.formatted(date: .omitted, time: .shortened))に撮った写真"))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
