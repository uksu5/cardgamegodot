extends Node

var hbox_container: HBoxContainer
var Deck: TextureButton
var EnemyCardsContainer: Control

func add_player_card_on_screen(card):
	var card_sprite = TextureRect.new()
	# загрузка текстуры
	var tex_path = "res://Sprites/cards/" + card.to_lower() + ".png"
	card_sprite.texture = load(tex_path)

	card_sprite.custom_minimum_size = BaseCards.CARD_TEXURE_SIZE
	card_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# добавление во временного родителя для анимации
	Deck.add_child(card_sprite)
	GlobalScripts.show_with_fadein(card_sprite, 0.2)
	card_sprite.set_as_top_level(true)

	card_sprite.global_position = Deck.global_position

	var tween = create_tween()
	tween.tween_property(card_sprite, "global_position", hbox_container.global_position, 1.0)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	await tween.finished
	Deck.remove_child(card_sprite)
	hbox_container.add_child(card_sprite)
	if card_sprite:
		card_sprite.set_as_top_level(false)
	hbox_container.sort_children

func add_enemy_card_on_screen():
	var angle_step := 6.0
	var spacing_x := 9.0
	var drop_y := 3.0
	var local_drop_y = drop_y
	
	var card = TextureRect.new()
	card.texture = load("res://Sprites/cards/card_back.png")
	
	var card_size = Vector2(60, 90)
	card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card.custom_minimum_size = card_size
	card.size = card_size
	card.pivot_offset = Vector2(card_size.x / 2.0, card_size.y)
	
	var index = EnemyCardsContainer.get_child_count()
	var angle_step_multiplier = 1.0 + pow(index, 1.3) * 0.03
	
	# Считаем позицию и поворот
	if index == 0:
		card.position = Vector2(0.0, 0.0) - card.pivot_offset
	else:
		var step = ceil(index / 2.0)
		var multiplier := 0.0
		if index % 2 != 0: 
			multiplier = step
		else:              
			multiplier = -step
			local_drop_y = -drop_y
			
		card.rotation_degrees = multiplier * angle_step * angle_step_multiplier
		
		var target_x = multiplier * spacing_x - angle_step_multiplier
		var target_y = multiplier * local_drop_y
		card.position = Vector2(target_x, target_y) - card.pivot_offset
	
	card.z_index = 0
	
	# ОБЩИЙ КОД: Выполняется один раз в конце для любой карты
	EnemyCardsContainer.add_child(card)
	GlobalScripts.show_with_fadein(card, 0.2)
