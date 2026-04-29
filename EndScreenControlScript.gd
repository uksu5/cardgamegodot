extends Control


@export var ResultBanner := TextureRect
@export var ShaderOverlay := ColorRect
@export var ItemData := Resource
var prize_screen = preload("res://PrizeScreen.tscn").instantiate()
enum Results {WIN, LOSS, DRAW, UNDECIDED}
var result = Results.WIN

func _ready() -> void:
	show_result(result)

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
	add_child(prize_screen)
	prize_screen.z_index = 2
	var screen_size = get_viewport_rect().size
	var x_center = screen_size.x / 2.4
	var y_offset = screen_size.y * 0.01
	var y_final = (screen_size.y / 2) + y_offset
	prize_screen.global_position = Vector2(x_center, y_final)
func loss_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(0.74, 0.0, 0.0, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/loss_banner.PNG")
func draw_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(0.59, 0.59, 0.59, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/draw_banner.PNG")
