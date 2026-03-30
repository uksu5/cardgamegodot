extends Control
@export var angle_step := 6.0
@export var spacing_x := 4.0
@export	var drop_y := 3.0
func add_enemy_card_on_screen():
	var local_drop_y = drop_y
	var card = TextureRect.new()
	card.texture = load("res://sprites/cards/card_back.png")
	
	var card_size = Vector2(60, 90)
	card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card.custom_minimum_size = card_size
	card.size = card_size
	
	card.pivot_offset = Vector2(card_size.x/2.0, card_size.y)
	var index = get_child_count()
	# возведение количества карт index в степень 1.3 для нелинейного роста множителя угла
	var angle_step_multiplier = 1.0 + pow(index, 1.3) * 0.03
	# если враг берет первую карту - вращение не применяется, карта ставится, а функция прерывается
	if index == 0:
		card.position = Vector2(0.0, 0.0) - card.pivot_offset
		add_child(card)
		return
	# 
	var step = ceil(index / 2.0)
	var multiplier := 0.0
	if index % 2 != 0: 
		multiplier = step
	else:              
		multiplier = -step
		local_drop_y = -drop_y
	card.rotation_degrees = multiplier*angle_step*angle_step_multiplier
	
	var target_x = multiplier*spacing_x-angle_step_multiplier
	var target_y = multiplier*local_drop_y
	
	card.position = Vector2(target_x, target_y) - card.pivot_offset
	
	card.z_index = 0
	
	add_child(card)
