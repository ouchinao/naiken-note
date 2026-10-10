import Foundation

enum ExifDateParser {
    private static let format = "yyyy:MM:dd HH:mm:ss"
    private static let offsetFormat = "yyyy:MM:dd HH:mm:ssxxx"

    /// 時差が読めないときに nil を返さないのは、時差の書き方が機種ごとに違っても撮影日時そのものは使えるため
    static func date(from text: String, offset: String?) -> Date? {
        if let offset, let date = formatter(format: offsetFormat, timeZone: nil).date(from: text + offset) {
            return date
        }
        return formatter(format: format, timeZone: .current).date(from: text)
    }

    // MARK: - Private

    private static func formatter(format: String, timeZone: TimeZone?) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        if let timeZone {
            formatter.timeZone = timeZone
        }
        formatter.dateFormat = format
        return formatter
    }
}
