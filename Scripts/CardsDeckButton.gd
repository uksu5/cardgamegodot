extends TextureButton

@onready var CardController = $"../Enemy Card Control"
@onready var hbox_container = $"../CardsContainer/HBoxContainer"
@onready var logging_box = $"../Log label"

func _ready():
	pass

func _on_button_down():
	CardController.take_card_player()
# Появление карты на экране
