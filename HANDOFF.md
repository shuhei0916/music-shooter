# 引き継ぎメモ — 2026-07-10

## 現在のブランチ

`feature/blaster-kit-assets`（mainからは未マージ）

---

## 完了済み作業（このブランチ）

- `assets/kenney_blaster-kit_2.1/` に Kenney Blaster Kit v2.1 を追加
- `blaster-a.glb` を `scenes/objects/weapons/handgun/` にコピー
- `handgun.tscn` に `BlasterMesh` 子ノードとして blaster-a.glb をインスタンス化
  - 回転: GLBのネイティブ向き（+X向き）を Godot の前方（-Z）に向けるため Transform3D で90度回転済み
  - スケール: 0.5（handgun.tscnの transform に含まれる）
  - Muzzle ノードの Z オフセット: -0.3（銃口先端に合わせるため）

## 残タスク（このブランチ）

- [ ] Godotエディタで実際に起動し、blaster-a のスケール・回転・Muzzle位置を目視調整する
- [ ] 問題なければ main にマージする

---

## mainブランチの現状

直近の主なコミット:
- `feat: HandgunのメッシュをKenney Blaster Kit (blaster-a)に差し替える`
- `feat: MIDIチャンネルデバッグオーバーレイUIをmainにマージする`
- `feat: main.gdのコンソールデバッグ出力をゲーム内オーバーレイUIに切り替える`

実装済み機能:
- MIDI連動の自動発射（HandgunがMIDIチャンネル0のnote_onで発射）
- DebugOverlay UI（F2でトグル、チャンネルごとのMIDIイベントをリアルタイム表示）
- ゲート通過でHP/武器強化
- 敵のスポーンとHP管理

---

## todo.md から抜粋（未着手の主要タスク）

### コアロジック
- 体感の音と弾丸発射タイミングのズレ調節（難易度高・保留中）
- リザルト画面を文字だけのダイアログ用ラベルに変更
- 曲前カウントダウンをダイアログ用ラベルに表示
- チェストとゲートが重ならないようにする
- 弾丸の発射口 GunPoint ノードを player の子ノードとして追加
- 複数トラック対応（色違いの弾丸を発射位置ずらして発射）
- 敵の当たり判定を増やす（レーンの1/3を占める判定）
- MIDIのノート数カウントをデバッグUIに表示
- ゲートのスポーンをプール方式に切り替え＋レアリティ色分け
- スタートタイマーを拍子カウント（1,2,1,2,3,4）に
- 敵の強さ調整

### 武器・ゲームプレイ拡張
- 武器種を追加（追尾弾・放射フィールドなど）
- 武器発射エフェクトとプレイヤーアニメーション

### 演出・エフェクト
- HP変化エフェクト
- 敵死亡エフェクト
- 確定演出

### リファクタリング
- Weapon継承→composition化（武器種追加のタイミングで）
- spawner._get_spawn_progress() の midi_player 直接参照解消

---

## 開発環境メモ

- エンジン: Godot 4.6
- テスト実行:
  ```bash
  godot --headless --script addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit
  godot --headless --script addons/gut/gut_cmdln.gd -gdir=res://tests/integration -gexit
  ```
- アセットインポート（新しい GLB 等を追加した後に必要）:
  ```bash
  godot --headless --import
  ```
- TDD: t-wada式。1サイクル1コミット。mainマージ前は必ずユーザー許可を得ること。
