# Practical

iOS 向けの日本語・英字キーボード（自分用）。仕様は [docs/spec.md](docs/spec.md) を参照。

## 方針
- iOS には標準キーボードを拡張する仕組みがないため、独立したカスタムキーボード（Keyboard Extension）として作る。
- 最初のリリースから、標準キーボードの代わりに使う主キーボードにする。フリックによるかな入力と、かな漢字変換（AzooKeyKanaKanjiConverter と Zenzai）を載せる。
- 補助機能は後の段階で同じキーボードに追加する（段階計画は [docs/spec.md](docs/spec.md) の §7）。

## やりたいこと
- スニペット・定型文の挿入
- AI による校正・翻訳・言い換え（要フルアクセス）
- カーソル移動・範囲選択・編集操作
- アンドゥ（ホストアプリの取り消しは呼べないため、キーボード側で入力履歴を持つ）
- アプリ・ショートカットの起動（公式には非サポート。要調査）

## 参考
- [Raycast Manual: Keyboard](https://manual.raycast.com/ios/keyboard)
- [azooKey](https://github.com/azooKey/azooKey)（OSS の日本語キーボード・変換エンジン）
