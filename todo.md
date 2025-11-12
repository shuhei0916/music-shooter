- [ ] `Player` の HP 管理
	- [ ] `take_damage` はダメージが残存数未満なら減算し `hp_changed` を発火する
- [ ] `Bullet` の挙動
	- [ ] `_on_area_entered` は敵グループへの命中でダメージを与え弾を破棄する
	- [ ] `_on_visible_on_screen_notifier_3d_screen_exited` は画面外で弾を破棄する
- [ ] `Enemy` の振る舞い
	- [ ] `take_damage` は HP を減算し 0 以下で自身を破棄、正の値ならラベルを更新する
	- [ ] `set_hp` は HP を更新し表示ラベルを `Utils.format_number` の結果で更新する
	- [ ] `_on_body_entered` はプレイヤー接触で `player_collided_with_enemy` を発火し自身を破棄する
- [ ] `Gate` の振る舞い
	- [ ] `set_gate_properties` はゲート種別と値を更新してラベル表示に反映する
	- [ ] `_on_body_entered` はプレイヤー接触で `player_entered_gate` を発火し自身を破棄する
- [ ] `SongManager` の楽曲管理
	- [ ] `_scan_songs` は `music` ディレクトリの MIDI ファイル一覧を走査してソートする
	- [ ] `select_song` は存在する楽曲パスのみを選択状態にできる

### その他のタスク
- [ ] 敵の当たり判定を増やす（レーンの3分の１を占めるような判定に変更し、3レーンの敵がスポーンした際、いずれかにヒットしなくてはならないようにする）
- [ ] 成長曲線の可視化
	- [x] MIDI の tick と累積ノート数から座標を生成するユーティリティを TDD で追加する
	- [x] SongManager が成長曲線データを保持・参照可能にする
	- [x] DebugMidiUI に成長曲線グラフを描画する
		- [x] DebugMidiUI は成長曲線データを受け取ると GrowthCurveGraph に反映する
- [ ] 完奏したさいにトレッドミルを停止する

### Soawner関連
- [ ] spawner関連のリファクタリングを行う
	- [ ] mainシーンにスポーン位置ノード（左中央右の3種類？）を配置、タイマーも配置
	- [ ] タイマーが発火するごとにスポーン判定を行う設計を維持したまま、5の剰余の場合はゲート、それ以外はランダムで敵をスポーンするよう変更

### リファクタリング
- [ ] 不要なif debug_ui:の条件分岐をなくす
- [ ] GameUIとdebug_uiを統合してHUDとする（debug_uiの部分は依然としてF2キー押下でトグルするようにする）
- [ ] GroundとPlayerのみのシンプルな構成にし、テスト->リファクタリングのサイクルを行う。
	- [ ] Playerのon_enteredイヴェントなどは入門サンプルプロジェクトを参考にPlayer.gdの方に書く。
	
	
### 最小構成
- [x] Playerが左右移動する
- [x] Playerの移動がClampされ、Groundから落ちない
- [x] 5回に1回ゲートスポーンが呼ばれる
- [x] ゲートが定期的にスポーンする
- [x] ゲートがz軸正の方向に移動する
- [ ] Playerがゲートと衝突すると、ゲートが消滅し、PlayerのHPが変化する
- [x] スポーンに関連する実装をSpawner.gdに移す（やはり）
- [ ] 敵のスポーンを実装
