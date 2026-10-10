import Foundation

/// 数値入力欄の文字列を数値にする。空欄は「値なし」として受け付け、数字でなければnilを返す
enum NumberInput {
    /// 入力欄の値。`value` がnilなら空欄
    struct Parsed<Value> {
        let value: Value?
    }

    static func integer(from text: String) -> Parsed<Int>? {
        let normalized = normalize(text)
        if normalized.isEmpty {
            return Parsed(value: nil)
        }
        guard let value = Int(normalized), value >= 0 else {
            return nil
        }
        return Parsed(value: value)
    }

    static func decimal(from text: String) -> Parsed<Double>? {
        let normalized = normalize(text)
        if normalized.isEmpty {
            return Parsed(value: nil)
        }
        guard let value = Double(normalized), value >= 0 else {
            return nil
        }
        return Parsed(value: value)
    }

    static func text(from value: Double) -> String {
        if value == value.rounded() {
            return String(Int(value))
        }
        return String(value)
    }

    // MARK: - Private

    /// 前後の空白と桁区切りのカンマを除き、全角数字を半角にする
    private static func normalize(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
        return trimmed.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? trimmed
    }
}
