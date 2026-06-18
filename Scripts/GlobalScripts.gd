extends Node

enum MenuScreens {CASSETTE, MENU}

var choosed_menu_screen := MenuScreens.MENU

func show_with_fadein(obj: CanvasItem, time: float):
	var tween = create_tween()
	obj.modulate.a = 0.0
	obj.visible = true
	tween.tween_property(obj, "modulate:a", 1.0, time)
	
func hide_with_fadeout(obj: CanvasItem, time: float):
	var tween = create_tween()
	obj.modulate.a = 1.0
	tween.tween_property(obj, "modulate:a", 0.0, time)
	await tween.finished
	obj.visible = false
	
	
func create_black_color_rect():
	var color_rect = ColorRect.new()
	color_rect.color = Color()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.z_index = 10
	
func color_rect_fadeout():
	var color_rect = ColorRect.new()
	color_rect.color = Color()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.z_index = 10
	add_child(color_rect)
	await hide_with_fadeout(color_rect, 1.0)
	
func load_resources_from_dir(folder_path: String, target_array: Array) -> void:
	target_array.clear() # Очищаем переданный массив перед заполнением
	
	if not folder_path.ends_with("/"):
		folder_path += "/"
	
	var dir = DirAccess.open(folder_path)
	if dir: 
		dir.list_dir_begin() 
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.contains(".tres"):
					var clean_file_name = file_name.replace(".remap", "")
					var loaded_item = load(folder_path + clean_file_name)
					if loaded_item:
						target_array.append(loaded_item)
						print("Успешно загружен ресурс: ", clean_file_name)
			
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("не доступен путь:", folder_path)
	
	# Проверка на пустоту
	if target_array.is_empty():
		print("массив пуст, путь", folder_path)
