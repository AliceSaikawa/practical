# AGENTS.md

仕様は [docs/spec.md](docs/spec.md) を正とする。決定には `D-xx` の ID が付いている。

## 判断が要る規則

ここには、仕組みで強制できない判断だけを書く。

- 設定画面の項目は、頻繁に変えるもの（触覚、トグル入力、変換モデル）に限る。それ以外の調整はコードを書き換えてビルドし直す（D-40）。項目を足す前に、本当に頻繁に変えるかを確かめる。
- 同じ種類の誤りが2回起きたら、下の「観察中の誤り」から規則に格上げし、強制手段（設計、型、リンター、テストの順に検討）を同じ変更で足す。1回目は「観察中の誤り」に記録するだけにする。

## 規則と強制手段

| 規則 | 強制手段 |
|---|---|
| Mac でのビルド・テスト・インストールは `scripts/mac <command>` を通す。Linux に Swift を入れない（D-63） | 設計：`scripts/mac` が同期と SSH 実行を受け持ち、Mac 側の手順は `scripts/on-mac/` だけに置く |
| 設定画面の項目を増やさない（D-40） | 文書：上の「判断が要る規則」 |
| Xcode の設定は `project.yml` だけで変える。`.xcodeproj` と拡張の `Info.plist` は生成物で、Git に入れない（D-62） | 設計：`.gitignore` で除外し、`scripts/on-mac/gen` が毎回生成する |
| iPhone のみ・iOS 17 以上、完全アクセスを求める、Bundle ID は `APP_BUNDLE_ID` から作る（D-03、D-04、D-64） | 設計：`project.yml` の1か所で定義する。`Package.swift` の `.iOS(.v17)` もそろえる |
| UI テストのターゲットを作らない（D-72） | 設計：`project.yml` にテストターゲットを置かない。テストは `PracticalKit` だけ |
| 入力・変換・設定のロジックは共有パッケージ `PracticalKit` に置く（D-60） | 設計：単体テストは `PracticalKit` にしかない（`scripts/mac test`） |
| テストするモジュールは UIKit に依存しない（D-61） | 設計：テストを macOS の `swift test` で実行するため、`import UIKit` があるとビルドが失敗する |
| Swift の整形は手で直さず `scripts/mac format` で揃える | リンター：`scripts/mac lint`（`swiftformat --lint` と `swiftlint --strict`）。独自ルールは足さず、2回起きた誤りだけを足す |
| 自分で書く Swift は Swift 6 言語モードで、警告を残さない | 型：`Package.swift` の `swiftLanguageModes: [.v6]` と `treatAllWarnings(as: .error)`、`project.yml` の `SWIFT_VERSION: "6.0"` と `SWIFT_TREAT_WARNINGS_AS_ERRORS` |

## 観察中の誤り

1回起きた誤りを、日付と PR のリンク付きで記録する。2回目が起きたら規則に格上げする。

（まだない）
