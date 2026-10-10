import Foundation
import Testing
@testable import Features

struct NumberInputTests {
    @Test("空欄は値なしとして受け付ける")
    func emptyTextHasNoValue() {
        #expect(NumberInput.integer(from: "  ")?.value == nil && NumberInput.integer(from: "  ") != nil)
    }

    @Test("カンマと全角数字を整数にする", arguments: ["85,000", "８５０００", " 85000 ", "８５，０００"])
    func parsesFormattedInteger(text: String) {
        #expect(NumberInput.integer(from: text)?.value == 85_000)
    }

    @Test("数字でない文字が入っていれば受け付けない", arguments: ["八万", "12a"])
    func rejectsNonNumericInteger(text: String) {
        #expect(NumberInput.integer(from: text) == nil)
    }

    @Test("負の数は受け付けない")
    func rejectsNegativeNumber() {
        #expect(NumberInput.integer(from: "-1") == nil && NumberInput.decimal(from: "-0.5") == nil)
    }

    @Test("小数点付きの面積を読む", arguments: [("25.5", 25.5), ("２５．５", 25.5), ("1,025.5", 1_025.5)])
    func parsesDecimal(text: String, expected: Double) {
        #expect(NumberInput.decimal(from: text)?.value == expected)
    }

    @Test("無限大や数でない値は面積として受け付けない", arguments: ["inf", "nan", "1e400"])
    func rejectsNonFiniteDecimal(text: String) {
        #expect(NumberInput.decimal(from: text) == nil)
    }

    @Test("整数の面積は小数点なしで表示する")
    func formatsWholeNumberWithoutFraction() {
        #expect(NumberInput.text(from: 30.0) == "30")
    }

    @Test("整数に収まらない大きな面積も表示できる")
    func formatsHugeNumber() {
        #expect(NumberInput.text(from: 1e20) == "1e+20")
    }
}
