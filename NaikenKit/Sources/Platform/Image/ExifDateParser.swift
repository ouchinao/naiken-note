import Foundation

/// EXIFの日時文字列("2026:10:01 14:30:00")を `Date` にする。時差がなければ端末のタイムゾーンとみなす
enum ExifDateParser {
    private static let format = "yyyy:MM:dd HH:mm:ss"
    private static let offsetFormat = "yyyy:MM:dd HH:mm:ssxxx"

    static func date(from text: String, offset: String?) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        if let offset {
            formatter.dateFormat = offsetFormat
            return formatter.date(from: text + offset)
        }
        formatter.timeZone = .current
        formatter.dateFormat = format
        return formatter.date(from: text)
    }
}
