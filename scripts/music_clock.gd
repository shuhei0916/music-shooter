class_name MusicClock
extends SongClock
## 曲の再生位置を時刻とする時計

var _player: AudioStreamPlayer
var _finished := false


func _init(player: AudioStreamPlayer) -> void:
	_player = player
	_player.finished.connect(func(): _finished = true)


func start() -> void:
	_player.play()


func time() -> float:
	if _finished:
		return duration()
	if not _player.playing:
		return _player.get_playback_position()
	return (
		_player.get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency()
	)


func duration() -> float:
	return _player.stream.get_length()
