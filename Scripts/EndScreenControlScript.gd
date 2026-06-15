extends Control


@export var ResultBanner := TextureRect
@export var ShaderOverlay := ColorRect
@export var ItemData := Resource
@export var PrizePanel := CanvasLayer
@export var PrizePanelScript := Script
@export var CassetteButton := Area2D

@export var ButtonsGroup: Node
@export var ExitTimerLabel: Label

@export var ExitTimer: Timer

var prize_screen = preload("res://PrizeScreen.tscn").instantiate()
enum Results {WIN, LOSS, DRAW, UNDECIDED}
var result = Results.UNDECIDED

func _ready() -> void:
	show_result(result)

func show_result(result):
	match result:
		Results.WIN:
			win_screen()
			ExitTimerLabel.queue_free()
		Results.LOSS:
			loss_screen()
			delete_buttons_from_scene()
		Results.DRAW:
			draw_screen()
			delete_buttons_from_scene()
			
func win_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(1.0, 0.885, 0.497, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/win_banner.PNG")

func loss_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(0.74, 0.0, 0.0, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/loss_banner.PNG")
	
func draw_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(0.59, 0.59, 0.59, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/draw_banner.PNG")

func delete_buttons_from_scene():
	ButtonsGroup.queue_free()
	ExitTimer.start()
	await ExitTimer.timeout
