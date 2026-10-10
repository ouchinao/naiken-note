import Foundation

enum NumberInput {
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

    private static func normalize(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
        return trimmed.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? trimmed
    }
}
