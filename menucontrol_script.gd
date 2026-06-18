extends Control

@export var MainMenuScreen: Control
@export var CassetteScreen: Control

func _ready() -> void:
	MainMenuScreen.scene_owner = self
	CassetteScreen.scene_owner = self
	SaveScript._load_data()
	match GlobalScripts.choosed_menu_screen:
		GlobalScripts.MenuScreens.CASSETTE:
			GlobalScripts.show_with_fadein(CassetteScreen, 1.0)
		GlobalScripts.MenuScreens.MENU:
			GlobalScripts.show_with_fadein(MainMenuScreen, 1.0)
