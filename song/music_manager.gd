extends Node

@onready var audio_player = $AudioStreamPlayer

var music_tracks = [
	preload("res://song/Dance With the dance Robeast.mp3"),
	preload("res://song/Dance With the dance.mp3"),
	preload("res://song/Andy James Shattered and Broken.mp3"),
	preload("res://song/Zombie Hyperdrive Argon Prime.mp3"),
	preload("res://song/Dance With the Dead A new Fear.mp3"),
]

var played_tracks = []  # Список уже сыгранных треков

func _ready():
	play_random_track()

func play_random_track():
	# Если все треки были сыграны, сбрасываем список
	if played_tracks.size() == music_tracks.size():
		played_tracks.clear()
	
	# Выбираем случайный трек, который еще не играл
	var random_index
	while true:
		random_index = randi_range(0, music_tracks.size() - 1)
		if random_index not in played_tracks:
			break
	
	played_tracks.append(random_index)
	audio_player.stream = music_tracks[random_index]
	audio_player.play()
	audio_player.finished.connect(_on_track_finished, CONNECT_ONE_SHOT)  # Одноразовое подключение

func _on_track_finished():
	play_random_track()
