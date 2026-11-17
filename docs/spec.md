# Practical 仕様書

iOS 向けの日本語・英字カスタムキーボード（自分用）。2026-11-17 の仕様決定セッションの結果をまとめる。

各決定には ID（`D-xx`）を振る。リンターやルールで決定を強制するときは、この ID を参照する。

## 1. 目的と前提

| ID | 決定 |
|---|---|
| D-01 | 自分用。App Store には出さず、手元の実機（無料の開発者アカウント）で使う。7日ごとの再インストールが苦痛なら有料登録に切り替える。 |
| D-02 | 配列・変換・辞書をすべて自分向けに最適化した、標準キーボードの代わりに使う主キーボードを作る。 |
| D-03 | 対象は iPhone のみ、iOS 17 以上。主な利用端末は iPhone 17 Pro Max。iPad は対象外。 |
| D-04 | 完全アクセス（`RequestsOpenAccess`）を求める。主な理由は触覚フィードバックと App Group への書き込み。 |
| D-05 | かな漢字変換は端末内だけで行い、入力内容を外部に送らない。通信は AI 機能を明示的に呼んだときだけ行う（AI 機能は第7段階）。 |

## 2. 最初のリリース（v1）の範囲

v1 に含めるもの：フリックによるかな入力、かな漢字変換、候補バー、英字（QWERTY）と数字・記号への切り替え、触覚フィードバック。

v1 に含めないもの：ローマ字入力、英語の予測、ユーザー辞書、学習、ライブ変換、スニペット、AI、編集操作（§7 の段階計画を参照）。

### 2.1 入力モードと配列

| ID | 決定 |
|---|---|
| D-10 | 入力モードは「あいう → ABC → ☆123」の順に切り替える。 |
| D-11 | あいう：iOS 標準の12キーフリック配列を再現する。のちに独自配列へ移る。 |
| D-12 | トグル入力（同じキーの連打で「あ→い→う」と進む入力）を設定でオン・オフできる。初期値はオフ。 |
| D-13 | 長押しでフリック方向のガイドを表示する。濁点・小文字キーの動きは標準と同じ。 |
| D-14 | ABC：QWERTY 配列。のちのローマ字入力の土台にする。 |
| D-15 | ☆123：iOS 標準と同じ12キーの数字・記号配列。のちに QWERTY 配列側の数字・記号ページも追加する。 |
| D-16 | 配列（キーの位置、フリックの割り当て）はコードに直接書かず、データ（Swift の型の値または JSON）で定義する。標準の12キー配列も、この形式で書く。 |
| D-17 | 地球儀キー（次のキーボードへの切り替え）を置く。 |

### 2.2 かな漢字変換

| ID | 決定 |
|---|---|
| D-20 | 変換エンジンは AzooKeyKanaKanjiConverter と Zenzai を使う。辞書と従来のエンジンが変換案を作り、小型モデル zenz がそれを検証する。LLM だけで変換する方式は採らない。 |
| D-21 | zenz は CPU で推論する（`ZenzaiCPU`）。GPU と Neural Engine はキーボード拡張で使えるか分からないため、使わない。 |
| D-22 | 標準は small モデルで推論3回（azooKey の「エフォート：高」に相当）。設定で xsmall モデルに切り替えられる。2026-11-17 時点の最新は zenz-v3.2-small（xsmall も v3.2）。 |
| D-23 | 直前の文章（左文脈）は最大20文字まで渡す。 |
| D-24 | 変換の操作は iOS 標準と同じ方式。入力中の文字に下線を付け、候補バーから選んで確定する。候補バーは広げて一覧にできる。ライブ変換は v1 には入れない。 |
| D-25 | あなた向けの最適化は、エンジンの外側（ユーザー辞書、学習、プロフィール、左文脈）で行う。zenz の追加学習は、それで足りないと分かったときの将来の課題にする。 |

### 2.3 触覚フィードバック

| ID | 決定 |
|---|---|
| D-30 | iOS 標準と同じ動作にする。振動はキーに触れたときの1回だけ出し、フリックの方向が決まったときには出さない。 |
| D-31 | 独自にオン・オフの設定を持つ（初期値はオン）。iOS 側の「キーボードのフィードバック」の設定は読み取れない前提で作る。 |
| D-32 | クリック音は付けない。 |
| D-33 | 完全アクセスがなく触覚を出せないときは、キーボード上に警告を表示する。 |

### 2.4 設定

| ID | 決定 |
|---|---|
| D-40 | 配列や挙動の細かい調整は、コードを書き換えてビルドし直す。頻繁に変える項目（触覚、トグル入力、変換モデル）だけを設定画面に置く。 |
| D-41 | 設定画面は本体アプリに置き、App Group を通してキーボードに渡す。無料アカウントで App Group が使えない場合は、設定画面をキーボードの中に移すか有料登録に切り替える（その時点で決める）。 |

## 3. 受け入れ条件（v1）

| ID | 条件 |
|---|---|
| D-50 | 1文字打つごとの候補の更新が、中央値で 40ms 以下。超えた場合は、まず推論回数を3回から1回に減らし、それでも超えるなら xsmall に切り替える。 |
| D-51 | メモリ使用量（`phys_footprint`）の最大値を記録し、上限で強制終了されないことを確かめる。 |
| D-52 | 計測は開発用ビルドだけで行い、`os_signpost` かログで確認する。 |

## 4. 構成と開発環境

| ID | 決定 |
|---|---|
| D-60 | 構成は、本体アプリ（設定）、キーボード拡張、共有ライブラリ（Swift Package：入力の状態管理、フリックの判定、変換エンジンとの接続、設定）の3つ。 |
| D-61 | 画面は SwiftUI で作り、`UIInputViewController` の中に表示する。タッチ処理の遅延が問題になった部分だけ UIKit に切り替える。 |
| D-62 | Xcode のプロジェクトは XcodeGen の `project.yml` から生成する。生成した `.xcodeproj` は Git で管理しない。 |
| D-63 | コードは Linux 上のリポジトリを正とし、`rsync` で Mac に同期する。ビルド、テスト、iPhone へのインストールは SSH 越しに Mac で行う（`xcodebuild`、`devicectl`）。Linux には Swift を入れない。 |
| D-64 | 名前は「Practical」（仮）。Bundle ID は `com.alicesaikawa.practical`、キーボード拡張は `com.alicesaikawa.practical.keyboard`、App Group は `group.com.alicesaikawa.practical`。他と重なる場合は末尾に文字を足す。 |

開発環境（2026-11-17 時点の確認結果）：

- Mac：MacBook Air（Apple Silicon、メモリ16GB）、macOS 27.2、Xcode 27.3 ベータ、Swift 6.4.2、Homebrew あり。SSH の接続名は `mac`。
- iPhone 17 Pro Max が Mac とペアリング済み。開発用の署名証明書（Apple Development）が1つある。
- iOS シミュレーターは iOS 26.2 だけ。シミュレーターは追加しない。

## 5. テスト

| ID | 決定 |
|---|---|
| D-70 | 単体テスト（Mac で実行する）：フリックの判定、入力状態の遷移（入力中・変換中・確定、濁点、小文字）、配列データの読み込み、変換エンジンとの接続（読みを入れて候補が返ること）。 |
| D-71 | 触覚、実際の文字入力、メモリ、遅延は実機だけで確認する。手順はチェックリストにする。 |
| D-72 | キーボード拡張の UI テストは作らない。 |

## 6. ライセンスと依存

2026-11-17 時点の調査結果。自分用なので、ライセンス上の義務は記録だけ行う。

| 依存 | 取り込み方 | ライセンス |
|---|---|---|
| [AzooKeyKanaKanjiConverter](https://github.com/azooKey/AzooKeyKanaKanjiConverter) | SwiftPM。最新は v0.11.2（2026-04-18）。`swift-tools-version: 6.1`、最低 iOS 17。trait `ZenzaiCPU` を指定する。 | MIT |
| 辞書 [azooKey_dictionary_storage](https://github.com/ensan-hcl/azooKey_dictionary_storage) | 変換エンジンの git submodule。product `KanaKanjiConverterModuleWithDefaultDictionary` に SwiftPM のリソースとして入る（約35MB）。`KanaKanjiConverter.withDefaultDictionary()` で使う。 | Apache-2.0 |
| 絵文字辞書 [azooKey_emoji_dictionary_storage](https://github.com/azooKey/azooKey_emoji_dictionary_storage) | 同上（約3.3MB） | 不明（LICENSE ファイルなし） |
| llama.cpp（[azooKey のフォーク](https://github.com/azooKey/llama.cpp)） | 変換エンジンが、署名済みのビルド済み xcframework（b4846 に固定、約66MB）として取り込む。 | MIT |
| zenz-v3.2-small / xsmall（[HuggingFace](https://huggingface.co/Miwa-Keita/zenz-v3.2-small-gguf)） | gguf（Q5_K_M、small 約74MB、xsmall 約21MB）をキーボード拡張のリソースに入れ、`zenzaiMode: .on(weight:…, versionDependentMode: .v3(…))` の `weight` にファイルの URL を渡す。azooKey 本体と同じ方式。 | CC-BY-SA-4.0（追加学習したモデルにも同じライセンスが付く） |

補足：

- 辞書のパスを `ConvertRequestOptions.dictionaryResourceURL` で渡す方法は廃止された。学習データは `memoryDirectoryURL`、ユーザ辞書などは `sharedContainerURL` に置く。
- 変換エンジンの README には「iOS 16 以降」とあるが、`Package.swift` は iOS 17 を最低にしている。`Package.swift` を正とする。

## 7. 段階計画（v2 以降）

1. 変換の最適化：ユーザー辞書、学習、ライブ変換（遅延の計測結果を見て決める）。
2. 編集操作：カーソル移動、範囲選択、キーボード側で持つアンドゥ（ホストアプリの取り消しは呼べないため、入力履歴をキーボードで持つ）。
3. スニペット・定型文。
4. ローマ字入力と、QWERTY 配列側の数字・記号。
5. 英語：予測・補完、そのあと自動修正。
6. 独自のフリック配列。
7. AI 機能：校正、翻訳、言い換え。接続先（クラウドの API か Apple Foundation Models か）、API キーの管理、操作の流れは、この段階で決める。
8. アプリやショートカットの起動（公式には非対応。調べてから決める）。

## 8. 未解決・実機で確かめること

- Mac のディスクに 20GB 以上の空きを作る（ユーザーが対応中）。
- 無料アカウントで App Group が使えるか（D-41）。
- 触覚フィードバックに完全アクセスが必要か（D-04、D-33）。情報源によって見解が分かれている。
- キーボード拡張のメモリ上限の実際の値。Apple は公表しておらず、実測の報告は 60〜70MB 程度。新しい端末ではもっと大きいという未確認の話もある。
- 辞書（約35MB）と small モデル（約74MB）を同時に使ってもメモリ上限に収まるか（D-22、D-51）。azooKey は同じ構成を iPhone 15 Pro 以上で推奨している。
- 依存を合わせると、アプリのサイズは 200MB 前後になる見込み。Mac の空き容量に影響する。
- iOS 標準キーボードの触覚が、キーに触れたときの1回だけであること（D-30）。

## 参考

- [Raycast Manual: Keyboard](https://manual.raycast.com/ios/keyboard)
- [azooKey](https://github.com/azooKey/azooKey) / [AzooKeyKanaKanjiConverter](https://github.com/azooKey/AzooKeyKanaKanjiConverter)
- [Zenzai の解説（Zenn）](https://zenn.dev/azookey/articles/ea15bacf81521e)
- [Zenzai のドキュメント](https://github.com/azooKey/AzooKeyKanaKanjiConverter/blob/main/Docs/zenzai.md)
