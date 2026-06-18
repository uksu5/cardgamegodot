extends Control

var scene_owner

func _on_button_main_menu_play_down() -> void:
	await GlobalScripts.hide_with_fadeout(self, 0.5)
	var color_rect = ColorRect.new()
	color_rect.color = Color()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.z_index = 10
	add_child(color_rect)
	await GlobalScripts.show_with_fadein(color_rect, 3.0)
	get_tree().change_scene_to_file("res://main_scene.tscn")
	
func _on_button_cassette_menu_down() -> void:
	await GlobalScripts.hide_with_fadeout(self, 0.5)
	GlobalScripts.show_with_fadein(scene_owner.CassetteScreen, 0.5)
