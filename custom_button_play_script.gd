extends TextureRect

var main_game_scene = preload("res://main_scene.tscn")
var button_texture = preload("res://Sprites/Buttons/button_menu.png")
var button_texture_hovered = preload("res://Sprites/Buttons/button_menu_hovered.png")
@onready var button = $Button
@onready var button_label = $ButtonLabel

var button_label_colors: Dictionary = {
	"normal": Color(1.0, 0.643, 0.259, 1.0),
	"hovered": Color(1.0, 0.839, 0.549, 1.0)
}


func _on_button_mouse_entered() -> void:
	texture = button_texture_hovered
	button_label.add_theme_color_override("font_color", button_label_colors["hovered"])

func _on_button_mouse_exited() -> void:
	texture = button_texture
	button_label.add_theme_color_override("font_color", button_label_colors["normal"])
