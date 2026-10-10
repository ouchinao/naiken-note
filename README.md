# 内見ノート (Naiken Note)

内見した物件の写真・採寸・チェック結果を1件ずつまとめ、比較表の画像として家族や同棲相手に共有できるiOSアプリ。
サーバを持たず、データは端末ローカルとユーザー自身のiCloudにだけ置く。

- 対象: iOS 17以上、iPhone専用
- 言語: Swift 6(Strict Concurrency)、SwiftUI + Observation、SwiftData + CloudKit、StoreKit 2
- 外部ライブラリ: なし(SwiftLintのビルドプラグインのみ)

## 構成

```
NaikenNote.xcodeproj   アプリとウィジェットのXcodeプロジェクト
NaikenApp/             Appターゲット(Composition Root、RootView、アセット)
NaikenWidget/          ウィジェット拡張(次の内見予定)
NaikenKit/             ローカルSwiftPMパッケージ
  Sources/Domain        Entity、UseCase、Repository / Service の protocol(Foundationのみ)
  Sources/Data          SwiftDataの @Model と Repository 実装
  Sources/Platform      画像処理、StoreKit、PhotoKit、ARセッション、ウィジェット更新
  Sources/DesignSystem  色・余白・共通部品
  Sources/Features      画面ごとの View + ViewModel、Router、EntitlementStore
  Tests/                Swift Testing によるユニットテスト
Config/                Info.plist と entitlements
NaikenNote.storekit    StoreKit Configuration(Xcodeでの購入テスト用)
```

依存は外側から内側へ(App → Features → Domain、App → Data / Platform → Domain)。
`Features` は `Data` と `Platform` を知らず、`Package.swift` の `dependencies` で機械的に守られる。

## 実機で動かす前に

識別子は仮の `com.example.naikennote` になっている。次の場所を自分のものに置き換える。

| 場所 | 値 |
| --- | --- |
| Xcode の Signing & Capabilities(NaikenNote と NaikenWidgetExtension) | Team と Bundle Identifier |
| `Config/NaikenNote/NaikenNote.entitlements` | iCloudコンテナ、App Group |
| `Config/NaikenWidget/NaikenWidget.entitlements` | App Group |
| `NaikenKit/Sources/Data/ModelContainerFactory.swift` | iCloudコンテナID |
| `NaikenKit/Sources/Domain/Entities/ProductID.swift`、`SharedStorage.swift` | Product ID、App Group ID |
| `NaikenNote.storekit` | Product ID |

リリース前に CloudKit Console で Development のスキーマを Production へデプロイする。
忘れると TestFlight 配布後に同期が無言で失敗する。

## テスト

```sh
cd NaikenKit
xcodebuild test -scheme NaikenKit -destination 'platform=iOS Simulator,name=iPhone 16' -skipPackagePluginValidation
```

アプリ全体のビルド:

```sh
xcodebuild build -project NaikenNote.xcodeproj -scheme NaikenNote \
  -destination 'generic/platform=iOS Simulator' -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO
```

GitHub Actions(`.github/workflows/ci.yml`)が push ごとに次を確かめ、どれかが失敗したら CI を落とす。

| 項目 | 内容 |
| --- | --- |
| 依存関係 | `scripts/check-dependencies.py` がターゲット間の依存方向と、外部パッケージが SwiftLint だけであることを確かめる。パッケージは `Package.resolved` に書かれた版だけを使い、書き換わったら失敗にする |
| lint | SwiftLint を `--strict` で回す(警告も失敗)。層ごとに import してよいフレームワークも `.swiftlint.yml` の `custom_rules` で縛る |
| テスト | `NaikenKit` の全テストを iOS シミュレータで回す |
| ビルド | アプリとウィジェットをビルドする |

SwiftLint の本体は、ビルドプラグインが取ってくるものと同じ版を CI でも使う。
カメラ、ARKit、StoreKit Sandbox、CloudKit同期は実機で手動確認する。

## ライセンス

[LICENSE](LICENSE) を参照。
