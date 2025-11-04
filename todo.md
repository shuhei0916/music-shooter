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

## その他のタスク
- [ ] 敵の当たり判定を増やす（レーンの3分の１を占めるような判定に変更し、3レーンの敵がスポーンした際、いずれかにヒットしなくてはならないようにする）
- [ ] 音源から敵の強さや頻度、アイテムの頻度などを計算するゲームマネージャーを作成する（プレイヤーの成長曲線）。

- [ ] 完奏したさいにトレッドミルを停止する
