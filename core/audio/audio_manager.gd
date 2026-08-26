class_name AudioManagerService
extends Node

signal music_changed(stream: AudioStream)
signal master_volume_changed(volume_db: float)

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	add_child(_music_player)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SfxPlayer"
	add_child(_sfx_player)

func play_music(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	_music_player.stream = stream
	_music_player.volume_db = volume_db
	_music_player.play()
	music_changed.emit(stream)

func stop_music() -> void:
	_music_player.stop()

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.volume_db = volume_db
	_sfx_player.play()

func set_master_volume_db(volume_db: float) -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	master_volume_changed.emit(volume_db)
