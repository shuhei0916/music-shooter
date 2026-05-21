# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 言語

**回答は思考も含め、すべて日本語で行うこと。** 

## プロジェクト概要

MIDIの演奏に同期して自動で弾丸を発射する、**Arrow a Row** ライクな3Dレーンランゲーム。Godot 4.6 / GDScript で実装。

**コアループ**: プレイヤーを左右に操作してゲートを通過しHP・武器を強化 → MIDIの演奏に合わせて武器が自動発射 → 完奏（曲の最後まで生き残る）を目指す。

**主要コンセプト**:
- **MIDIチャンネル = 武器種**: ドラム(ch9)=ハンドガン、ギター=追尾弾、ボーカル=ハンドガン、ベース=放射フィールド（将来設計）
- **ビルド構築**: Vampire Survivors 的に、ゲートやドロップで武器を強化しながら敵の波を生き抜く
- **終了条件**: 完奏（MIDIが最後まで再生される）またはHP0によるゲームオーバー

## テストコマンド

テストフレームワーク: **GUT (Godot Unit Test)**

```bash
# 全テスト実行
godot --headless --script addons/gut/gut_cmdln.gd -gdir=res://tests/ -ginclude_subdirs -gexit

# 単体テストのみ
godot --headless --script addons/gut/gut_cmdln.gd -gdir=res://tests/unit/ -gexit

# 統合テストのみ
godot --headless --script addons/gut/gut_cmdln.gd -gdir=res://tests/integration/ -gexit
```


## TDD ワークフロー（t-wada式）

**IMPORTANT: 必ずTDDに従って開発すること。省略・飛ばし禁止。**

1. **テストリスト作成** — `todo.md` に期待動作を列挙する（設計判断はしない）
2. 🔴 **Red** — テストリストから1つだけ取り出し、失敗するテストを書く
3. 🟢 **Green** — プロダクトコードを修正してそのテストと全テストを通す。`todo.md` の該当項目をチェック
4. 🔵 **Refactor** — 必要に応じてリファクタリング
5. **繰り返す** — テストリストが空になるまで

- **1テストケースにつき1アサーション**を原則とする
- **1サイクルにつき1コミット**（ユーザー確認後にコミット）
- コミットは **Conventional Commits** に従う

## アーキテクチャ

### シーン構成

```
scenes/
  main/main.tscn          # ゲームのルートシーン
  characters/
	player/player.tscn    # CharacterBody3D。移動・射撃・HP管理
	enemy/enemy.tscn      # Area3D。HPラベル付き、弾丸衝突でダメージ
  objects/
	bullet/bullet.tscn    # Area3D。前方に直進し画面外で自動削除
	gate/gate.tscn        # Area3D。プレイヤー通過時にHP効果を付与
  components/
	spawner.tscn          # Spawner独立シーン。SpawnTimer・AnchorRoot(Lane0〜2)含む
  ui/
	game_ui.tscn          # HUD（進行状況・カウントダウン・リザルト）
	main_menu.tscn
	components/growth_curve_graph.tscn
```

### Autoload（グローバルシングルトン）

| 名前 | ファイル |
|------|--------|
| Utils | `scripts/utils.gd` |
| SceneManager | `scripts/scene_manager.gd` |
| SongManager | `scripts/song_manager.gd` |

### ゲームフロー

1. **StartTimer** タイムアウト → `world_speed` を 0 → 5.0 に変更、SpawnTimer 開始、MidiPlayer 再生
2. **MidiPlayer** が `note_on` イベントを発火 → `main._on_midi_event` → チャンネル9（ドラム）で `player.shoot()`
3. 世界が移動（`world_objects` グループ全ノードをZ軸方向に `world_speed * delta` 移動）
4. **MIDI完奏** または **HP≤0** → `world_speed=0`、SpawnTimer停止、`game_ui.show_result()` 表示
5. Enter/Space で現在のシーンをリロード

### Spawner のロジック

- SpawnTimer タイムアウトごとに `spawn_counter` をインクリメント
- `spawn_counter % 5 == 0` のターン → AnchorRoot の全マーカー位置にゲート行を生成（add +5〜20）
- その他のターン → `enemy_spawn_probability`（デフォルト0.1）の確率で敵を1体スポーン

### ノードグループ

| グループ名 | 用途 |
|-----------|------|
| `world_objects` | メインループでZ軸移動させるオブジェクト |
| `player` | Playerノードの識別（衝突判定用） |
| `bullet` | Bulletノードの識別（敵との衝突判定用） |
| `enemy` | Enemyノードの識別（スポーン数カウント用） |

### 物理レイヤー

| レイヤー | 用途 |
|---------|------|
| 1 | Player |
| 2 | Bullet |
| 3 | Item |
| 4 | Enemy |
| 5 | Ground |

## テスト構成

| 種別 | 場所 | 方針 |
|------|------|------|
| 単体テスト | `tests/unit/` | スクリプトを `new()` して直接テスト。シーンに依存しない |
| 統合テスト | `tests/integration/` | `main.tscn` などをインスタンス化してシーン全体でテスト |

- 単体テストで対応できない場合（Spawnerの統合など）は統合テストに落とす
- 統合テストは `add_child_autofree()` と `await get_tree().process_frame` を使う

## 参考プロジェクト

- `/home/shuhei0916/c/projects/GodotProjects/dodge_the_creeps`
- `/home/shuhei0916/c/projects/GodotProjects/squash_the_creeps_start_1.1.0`
