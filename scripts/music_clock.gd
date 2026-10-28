class_name MusicClock
extends SongClock
## 曲の再生位置を時刻とする時計

var _player: AudioStreamPlayer


func _init(player: AudioStreamPlayer) -> void:
	_player = player


func start() -> void:
	_player.play()


func time() -> float:
	if not _player.playing:
		return _player.get_playback_position()
	return (
		_player.get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency()
	)


func duration() -> float:
	return _player.stream.get_length()
