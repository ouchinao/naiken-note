import Foundation

/// 保存する画像の仕様
public enum ImageSpec {
    /// 保存時に縮小する長辺のピクセル数
    public static let maxPixelSize = 2_048
    /// サムネイルの長辺のピクセル数
    public static let thumbnailMaxPixelSize = 320
    /// JPEGの圧縮品質
    public static let jpegQuality = 0.8
}
