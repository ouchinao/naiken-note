import Foundation

public enum ImageSpec {
    /// 原寸で保存しないのは、1物件に50枚撮ってもユーザーのiCloud容量を圧迫しないようにするため
    public static let maxPixelSize = 2_048
    static let thumbnailMaxPixelSize = 320
    public static let jpegQuality = 0.8
}
