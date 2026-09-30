class_name CustomCard
extends Control

@onready var button: TextureButton = $CustomCardButton
var custom_card_name: String
var custom_card_description: String


const HOLD_TIME = GlobalScripts.CustomCardHoldTime
var current_time: float = 0.0
var is_holding = false

func _ready() -> void:
	set_names()
	var texture = self
	
	texture.custom_maximum_size = BaseCards.CARD_TEXURE_SIZE
	button.global_position = texture.global_position
	button.size = texture.size
	texture.custom_minimum_size = BaseCards.CARD_TEXURE_SIZE
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.set_as_top_level(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_holding:
		current_time += delta
		var progress: float = clamp(current_time / HOLD_TIME, 0.0, 1.0)
		var brightness = lerp(1.0, 3.0, progress)
		self_modulate = Color(brightness, brightness ,brightness, 1.0)
		if current_time >= HOLD_TIME:
			print("hui")
			custom_card_action()
	else:
		self_modulate = Color(1, 1, 1, 1)

func set_names():
	pass

func custom_card_action():
	pass
	
func show_card_banner():
	GlobalScripts.show_info(GlobalScripts.CardController, custom_card_name, custom_card_description)

func _on_button_down() -> void:
	is_holding = true


func _on_button_up() -> void:
	is_holding = false
