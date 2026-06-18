extends Control


@export var ResultBanner := TextureRect
@export var ShaderOverlay := ColorRect
@export var ItemData := Resource
@export var PrizePanel := CanvasLayer
@export var PrizePanelScript := Script
@export var CassetteButton := Area2D

@export var ButtonsGroup: Node2D
@export var ExitTimerLabel: Label

@export var ExitTimer: Timer
enum Results {WIN, LOSS, DRAW, UNDECIDED}
var result = Results.UNDECIDED

var menu_control_scene = load("res://menucontrol.tscn").instantiate()

func _ready() -> void:
	show_result(result)
	var banner_to_show = ResultBanner
	GlobalScripts.show_with_fadein(banner_to_show, 0.5)

func show_result(result):
	match result:
		Results.WIN:
			win_screen()
			ExitTimerLabel.queue_free()
		Results.LOSS:
			loss_screen()
#			delete_buttons_from_scene()
		Results.DRAW:
			draw_screen()
#			delete_buttons_from_scene()
			
func win_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(1.0, 0.885, 0.497, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/win_banner.PNG")

func loss_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(0.74, 0.0, 0.0, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/loss_banner.PNG")
	
func draw_screen():
	ShaderOverlay.material.set_shader_parameter("light_color", Color(0.59, 0.59, 0.59, 1.0))	
	ResultBanner.texture = load("res://Sprites/banners/draw_banner.PNG")


func _on_cassette_button_down() -> void:
	#GlobalScripts.choosed_menu_screen = GlobalScripts.MenuScreens.CASSETTE
	#get_tree().change_scene_to_file("res://menucontrol.tscn")
	get_tree().change_scene_to_file("res://main_scene.tscn")

func _on_menu_button_down() -> void:
	go_to_main_menu()

func go_to_main_menu():
	GlobalScripts.choosed_menu_screen = GlobalScripts.MenuScreens.MENU
	get_tree().change_scene_to_file("res://menucontrol.tscn")
