extends Node2D


var coin = 1


func _on_area_2d_area_entered(area):
	Global.coin_collected.emit(coin)
	queue_free()
