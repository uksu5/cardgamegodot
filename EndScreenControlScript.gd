extends Control


@export var ResultBanner := TextureRect
@export var ShaderOverlay := ColorRect
enum Results {WIN, LOSS, DRAW, UNDECIDED}
func _ready() -> void:
	pass

func show_result(result):
	match result:
		Results.WIN:
			win_screen()
		Results.LOSS:
			loss_screen()
		Results.DRAW:
			draw_screen()
			
func win_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(1.0, 0.885, 0.497, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/win_banner.PNG")
func loss_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(0.74, 0.0, 0.0, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/loss_banner.PNG")
func draw_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(0.59, 0.59, 0.59, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/draw_banner.PNG")
