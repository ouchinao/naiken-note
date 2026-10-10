import Foundation
import Testing
@testable import Domain

struct CheckItemCatalogTests {
    @Test("項目のキーは重複しない")
    func keysAreUnique() {
        let keys = CheckItemCatalog.all.map(\.id)

        #expect(Set(keys).count == keys.count)
    }

    @Test("どのカテゴリにも項目がある", arguments: CheckItem.Category.allCases)
    func everyCategoryHasItems(category: CheckItem.Category) {
        #expect(!CheckItemCatalog.items(in: category).isEmpty)
    }

    @Test("キーから項目を引ける")
    func findsItemByKey() {
        #expect(CheckItemCatalog.item(forKey: "waterPressure")?.category == .water)
    }
}
