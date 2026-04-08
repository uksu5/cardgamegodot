extends Node
@onready var cards_controller = $"../CardController"

func _ready() -> void:
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://shaders/grayscale.gdshader")
	for button in get_children():
		button.material = mat

func _process(delta: float):
	if cards_controller.current_turn == "player":
		disable_buttons(false)
	else:
		disable_buttons(true)
		

func disable_buttons(bool):
	for button in get_children():
		button.disabled = bool
		if bool:
			button.material.set_shader_parameter("saturation", 0.0)
		else:
			button.material.set_shader_parameter("saturation", 7.0)
