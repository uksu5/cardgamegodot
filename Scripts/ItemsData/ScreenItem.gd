extends Control

var data: ItemData
@onready var owner_scene
@export var sprite: TextureRect

func init(item):
	data = item
	sprite.texture = data.texture
	print(owner_scene)
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			owner_scene.write_item_data(data)
