import DesignSystem
import Domain
import PhotosUI
import SwiftUI

struct PhotosTabView: View {
    private static let cellMinimumWidth: CGFloat = 100

    @Bindable var viewModel: PhotosTabViewModel
    let property: Property
    @Environment(Router.self) private var router
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var captionTarget: Photo?
    @State private var captionText = ""

    init(viewModel: PhotosTabViewModel, property: Property) {
        self.viewModel = viewModel
        self.property = property
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                actionButtons
                tagFilter
                photoGrid
            }
            .padding()
        }
        .overlay {
            if viewModel.isImporting {
                ProgressView("取り込み中…")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CornerRadius.medium))
            }
        }
        .task(id: property.photos) { await viewModel.loadThumbnails(for: property.photos) }
        .onChange(of: pickerItems) { _, items in
            Task { await importPicked(items) }
        }
        .alert("キャプション", isPresented: isEditingCaption) {
            TextField("キャプション", text: $captionText)
            Button("保存") { saveCaption() }
            Button("キャンセル", role: .cancel) {}
        }
        .alert("確認", isPresented: $viewModel.isNoticePresented, presenting: viewModel.notice) { _ in
            Button("閉じる", role: .cancel) {}
        } message: { notice in
            switch notice {
            case .failed(let message):
                Text(message)
            }
        }
    }

    // MARK: - Private

    private var actionButtons: some View {
        HStack(spacing: Spacing.small) {
            Button {
                router.presentFullScreen(.camera(propertyID: property.id))
            } label: {
                Label("撮影", systemImage: "camera")
            }
            PhotosPicker(selection: $pickerItems, matching: .images) {
                Label("選んで追加", systemImage: "photo.on.rectangle")
            }
            Button {
                router.present(.libraryImport(propertyID: property.id))
            } label: {
                Label("自動で探す", systemImage: "sparkle.magnifyingglass")
            }
        }
        .buttonStyle(.bordered)
        .font(.subheadline)
    }

    private var tagFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.small) {
                Button {
                    viewModel.selectedTag = nil
                } label: {
                    TagChip(title: String(localized: "すべて", bundle: .module), isSelected: viewModel.selectedTag == nil)
                }
                ForEach(Photo.RoomTag.allCases, id: \.self) { tag in
                    Button {
                        viewModel.selectedTag = tag
                    } label: {
                        TagChip(title: tag.title, isSelected: viewModel.selectedTag == tag)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var photoGrid: some View {
        let photos = viewModel.photos(of: property)
        if photos.isEmpty {
            ContentUnavailableView("写真がありません", systemImage: "photo", description: Text("撮影するか、写真ライブラリから追加しましょう"))
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Self.cellMinimumWidth), spacing: Spacing.small)], spacing: Spacing.small) {
                ForEach(photos) { photo in
                    PhotoCell(
                        photo: photo,
                        thumbnail: viewModel.thumbnails[photo.id],
                        isRepresentative: photo == property.representativePhoto
                    )
                    .onTapGesture { router.presentFullScreen(.photo(id: photo.id)) }
                    .contextMenu { contextMenu(for: photo) }
                }
            }
        }
    }

    @ViewBuilder
    private func contextMenu(for photo: Photo) -> some View {
        Menu("部屋タグを変更") {
            ForEach(Photo.RoomTag.allCases, id: \.self) { tag in
                Button(tag.title) {
                    Task { await viewModel.changeTag(of: photo, to: tag) }
                }
            }
        }
        Button("キャプションを編集") {
            captionText = photo.caption
            captionTarget = photo
        }
        Button("代表写真にする") {
            Task { await viewModel.makeRepresentative(photo, in: property.id) }
        }
        Button("削除", role: .destructive) {
            Task { await viewModel.delete(photo) }
        }
    }

    private var isEditingCaption: Binding<Bool> {
        return Binding {
            return captionTarget != nil
        } set: { isPresented in
            if !isPresented {
                captionTarget = nil
            }
        }
    }

    private func saveCaption() {
        guard let captionTarget else {
            return
        }
        let caption = captionText
        Task { await viewModel.changeCaption(of: captionTarget, to: caption) }
    }

    /// 選んだ写真を `Data` にしてから ViewModel に渡す。写真ライブラリの権限は要らない
    private func importPicked(_ items: [PhotosPickerItem]) async {
        if items.isEmpty {
            return
        }
        var images: [Data] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                images.append(data)
            }
        }
        pickerItems = []
        await viewModel.importPhotos(images, into: property.id)
    }
}

private struct PhotoCell: View {
    let photo: Photo
    let thumbnail: Data?
    let isRepresentative: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    ThumbnailView(data: thumbnail)
                }
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            HStack(spacing: Spacing.xSmall) {
                if isRepresentative {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                TagChip(title: photo.roomTag.title)
            }
            .padding(Spacing.xSmall)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(photo.caption.isEmpty ? photo.roomTag.title : "\(photo.roomTag.title) \(photo.caption)")
    }
}
