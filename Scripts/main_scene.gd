extends Node2D

var end_screen = preload("res://EndScreen.tscn").instantiate()

func _input(event: InputEvent) -> void:
	# Проверяем, что событие — это именно нажатие клавиши на клавиатуре
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_F11:
			var current_mode = DisplayServer.window_get_mode()
			if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
