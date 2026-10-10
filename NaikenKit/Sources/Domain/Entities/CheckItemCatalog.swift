import Foundation

/// アプリ側で定義する定型チェック項目。キーは保存済みの `CheckResult.itemKey` と対応するので変更しない
public enum CheckItemCatalog {
    public static let all = [
        CheckItem(id: "sunlight", title: String(localized: "日当たり", bundle: .module), category: .environment),
        CheckItem(id: "ventilation", title: String(localized: "風通し", bundle: .module), category: .environment),
        CheckItem(id: "noise", title: String(localized: "騒音", bundle: .module), category: .environment),
        CheckItem(id: "smell", title: String(localized: "におい", bundle: .module), category: .environment),
        CheckItem(id: "view", title: String(localized: "窓からの眺め", bundle: .module), category: .environment),
        CheckItem(id: "waterPressure", title: String(localized: "水圧", bundle: .module), category: .water),
        CheckItem(id: "drainage", title: String(localized: "排水の流れ", bundle: .module), category: .water),
        CheckItem(id: "hotWater", title: String(localized: "お湯の出方", bundle: .module), category: .water),
        CheckItem(id: "bathroomMold", title: String(localized: "浴室のカビ・換気", bundle: .module), category: .water),
        CheckItem(id: "toilet", title: String(localized: "トイレの状態", bundle: .module), category: .water),
        CheckItem(id: "wallsAndFloor", title: String(localized: "壁・床の傷や汚れ", bundle: .module), category: .interior),
        CheckItem(id: "condensation", title: String(localized: "結露・カビの跡", bundle: .module), category: .interior),
        CheckItem(id: "outlets", title: String(localized: "コンセントの数と位置", bundle: .module), category: .interior),
        CheckItem(id: "mobileSignal", title: String(localized: "携帯の電波", bundle: .module), category: .interior),
        CheckItem(id: "airConditioner", title: String(localized: "エアコンの有無と年式", bundle: .module), category: .interior),
        CheckItem(id: "storageSpace", title: String(localized: "収納の広さ", bundle: .module), category: .storage),
        CheckItem(id: "closetDepth", title: String(localized: "クローゼットの奥行き", bundle: .module), category: .storage),
        CheckItem(id: "garbageArea", title: String(localized: "ゴミ置き場", bundle: .module), category: .common),
        CheckItem(id: "bicycleParking", title: String(localized: "駐輪場", bundle: .module), category: .common),
        CheckItem(id: "security", title: String(localized: "オートロック・防犯", bundle: .module), category: .common),
        CheckItem(id: "deliveryBox", title: String(localized: "宅配ボックス", bundle: .module), category: .common),
        CheckItem(id: "neighborhood", title: String(localized: "周辺の店・街灯", bundle: .module), category: .common),
    ]

    public static func item(forKey key: String) -> CheckItem? {
        return all.first { $0.id == key }
    }

    public static func items(in category: CheckItem.Category) -> [CheckItem] {
        return all.filter { $0.category == category }
    }
}
