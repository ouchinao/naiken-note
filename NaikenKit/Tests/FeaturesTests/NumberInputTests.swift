import Foundation
import Testing
@testable import Features

struct NumberInputTests {
    @Test("空欄は値なしとして受け付ける")
    func emptyTextHasNoValue() {
        #expect(NumberInput.integer(from: "  ")?.value == nil && NumberInput.integer(from: "  ") != nil)
    }

    @Test("カンマと全角数字を整数にする", arguments: ["85,000", "８５０００", " 85000 "])
    func parsesFormattedInteger(text: String) {
        #expect(NumberInput.integer(from: text)?.value == 85_000)
    }

    @Test("数字でなければnil", arguments: ["八万", "12a", "-1"])
    func rejectsInvalidInteger(text: String) {
        #expect(NumberInput.integer(from: text) == nil)
    }

    @Test("小数点付きの面積を読む")
    func parsesDecimal() {
        #expect(NumberInput.decimal(from: "25.5")?.value == 25.5)
    }

    @Test("整数の面積は小数点なしで表示する")
    func formatsWholeNumberWithoutFraction() {
        #expect(NumberInput.text(from: 30.0) == "30")
    }
}
