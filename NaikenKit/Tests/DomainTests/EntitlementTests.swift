import Foundation
import Testing
@testable import Domain

struct EntitlementTests {
    @Test("有効な Product ID がなければ free")
    func noProductIsFree() {
        #expect(Entitlement(activeProductIDs: []) == .free)
    }

    @Test("unlock だけが有効なら unlocked")
    func unlockOnlyIsUnlocked() {
        #expect(Entitlement(activeProductIDs: [ProductID.unlock]) == .unlocked)
    }

    @Test("Pro が有効なら pro")
    func proOnlyIsPro() {
        #expect(Entitlement(activeProductIDs: [ProductID.proMonthly]) == .pro)
    }

    @Test("unlock と Pro の両方が有効なら Pro を優先する")
    func proWinsOverUnlock() {
        #expect(Entitlement(activeProductIDs: [ProductID.unlock, ProductID.proMonthly]) == .pro)
    }

    @Test("知らない Product ID は無視する")
    func unknownProductIsIgnored() {
        #expect(Entitlement(activeProductIDs: ["com.example.unknown"]) == .free)
    }

    @Test("無料版で登録できるのは3件まで")
    func freeLimitIsThree() {
        #expect(Entitlement.free.propertyLimit == 3)
    }

    @Test("解錠済みなら登録件数の上限はない", arguments: [Entitlement.unlocked, .pro])
    func unlockedHasNoLimit(entitlement: Entitlement) {
        #expect(entitlement.propertyLimit == nil)
    }

    @Test("比較表の書き出しは解錠済みだけができる", arguments: [(Entitlement.free, false), (.unlocked, true), (.pro, true)])
    func exportRequiresUnlock(entitlement: Entitlement, expected: Bool) {
        #expect(entitlement.canExportComparison == expected)
    }

    @Test("顧客別フォルダは Pro だけが使える", arguments: [(Entitlement.free, false), (.unlocked, false), (.pro, true)])
    func customerFoldersRequirePro(entitlement: Entitlement, expected: Bool) {
        #expect(entitlement.canUseCustomerFolders == expected)
    }
}
