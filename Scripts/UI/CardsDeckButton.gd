extends TextureButton

@onready var CardController = $"../../CardController"
@onready var hbox_container = $"../../CardsContainer/HBoxContainer"
@onready var logging_box = $"../Log label"

func _ready():
	#BitMap - класс хранящий монохромные изображения, здесь используется для создания маски
	
	var texture = texture_normal.get_image()
	var bitmap = BitMap.new()
	# все что прозрачнее 0.5 - игнорируется
	bitmap.create_from_image_alpha(texture, 0.5)
	texture_click_mask = bitmap
func _on_button_down():
	CardController.take_card_player()
func add_card_on_screen(card):
	var card_sprite = TextureRect.new()
	# загрузка текстуры
	var tex_path = "res://sprites/cards/" + card + ".png"
	card_sprite.texture = load(tex_path)

	card_sprite.custom_minimum_size = Vector2(297, 497)
	card_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# добавление во временного родителя для анимации
	add_child(card_sprite)

	card_sprite.global_position = global_position

	var tween = create_tween()
	tween.tween_property(card_sprite, "global_position", hbox_container.global_position, 1.0)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	await tween.finished

	remove_child(card_sprite)
	hbox_container.add_child(card_sprite)
