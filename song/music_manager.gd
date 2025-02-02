extends Node

@onready var audio_player = $AudioStreamPlayer

var music_tracks = [
	preload("res://song/Dance With the dance Robeast.mp3"),
	preload("res://song/Dance With the dance.mp3"),
	#preload("res://song/levelscen.mp3")
]

var current_track_index = 0

func _ready():
	play_next_track()

func play_next_track():
	audio_player.stream = music_tracks[current_track_index]
	audio_player.play()
	audio_player.finished.connect(_on_track_finished)

func _on_track_finished():
	current_track_index = (current_track_index + 1) % music_tracks.size()
	play_next_track()
