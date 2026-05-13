extends Node

var turn := Turn.ENEMY
var BaseCards = load("res://Scripts/Cards/base_cards.gd")
var cards_rate = BaseCards.CARDS
var cards_suit = BaseCards.CARDS_SUITS
var cards_deck = BaseCards.CARDS_DECK52.duplicate()
var end_screen = preload("res://EndScreen.tscn").instantiate()
@onready var logging_box = $"../Log label"
@onready var hbox_container = $"../CardsContainer/HBoxContainer"
@onready var give_card_button_script = $"../Deck Buttons/CardsDeckButton"
@onready var enemy_cards_container = $"../EnemyCardsContainer"
@onready var turn_banner = $"../Turn Banner"



var game_result := Results.UNDECIDED

var enemy_cards:= []
var enemy_score := 0

var player_score = 0
var player_cards = []

enum Actions {HIT, STAND}
enum Turn {PLAYER, ENEMY}
enum GameState {PLAYER_TURN, ENEMY_TURN, GAME_OVER}
enum Results {WIN, LOSS, DRAW, UNDECIDED}

var state = GameState.PLAYER_TURN

var last_player_action = Actions.HIT
var last_enemy_action = Actions.HIT
	
func _ready():
	game_result = Results.UNDECIDED
	cards_deck.shuffle()
	choose_turn()
	SaveScript._load_data()
	print(GameData.inventory)
	
	
func choose_turn():
	# Случайный выбор хода(игрок/противник)
	turn = [Turn.PLAYER, Turn.ENEMY].pick_random()
	match turn:
		Turn.PLAYER:
			state = GameState.PLAYER_TURN
		Turn.ENEMY:
			state = GameState.ENEMY_TURN
	deferred_next_step()

func enemy_turn():
	state = GameState.ENEMY_TURN
	if enemy_cards.is_empty():
		take_card_enemy()
		return
	logging_box.add_log("Ход врага")
	await get_tree().create_timer(randf_range(2.0, 7.0)).timeout
	#запуск монте-карло
	var decision = monte_carlo()
	if decision == Actions.HIT:
		logging_box.add_log("Враг взял карту")
		take_card_enemy()
	else:
		logging_box.add_log("Враг НЕ берет карту")
		stand_enemy()

func monte_carlo() -> int:
	var iterations = 1000
	var win_counts = { Actions.HIT: 0, Actions.STAND: 0}
	#Запуск симуляций для каждого варианта 
	for action in [Actions.HIT, Actions.STAND]:
		for i in range(iterations):
			if simulate_game(action):
				win_counts[action] += 1
	#Проверка более выгодного действия и возврат его
	if win_counts[Actions.HIT] > win_counts[Actions.STAND]:
		return Actions.HIT
	return Actions.STAND
	
func simulate_game(starting_action):
	var sim_deck = cards_deck.duplicate()
	sim_deck.shuffle()
	
	var sim_enemy_cards = enemy_cards.duplicate()
	var sim_player_cards = player_cards.duplicate()
	
	# Ход врага (начальное действие)
	if starting_action == Actions.HIT:
		if sim_deck.is_empty(): return false
		sim_enemy_cards.append(sim_deck.pop_back())
		
	var sim_enemy_score = get_score(sim_enemy_cards)
	if sim_enemy_score > 21: 
		return false
	
	# Враг добирает до 17
	while sim_enemy_score < 17:
		if sim_deck.is_empty(): break
		sim_enemy_cards.append(sim_deck.pop_back())
		sim_enemy_score = get_score(sim_enemy_cards)
	
	var sim_player_score = get_score(sim_player_cards)
	
	while sim_player_score < 17:
		if sim_deck.is_empty(): break
		sim_player_cards.append(sim_deck.pop_back())
		sim_player_score = get_score(sim_player_cards)
	
	# Финальное сравнение
	if sim_player_score > 21:
		return true
	if sim_enemy_score > 21:
		return false
		
	return sim_enemy_score > sim_player_score
			
func player_turn():
	state = GameState.PLAYER_TURN
	logging_box.add_log("Ход игрока")
	
# ШТУЧКИ
func get_score(cards) -> int:
	var score = 0
	for card in cards:
		score += cards_rate[(card.substr(1, len(card)))]
	return score
	
func take_card_enemy():
	enemy_cards.append(cards_deck.pop_back())
	enemy_score = get_score(enemy_cards)
	logging_box.add_log("Карты врага: " + str(enemy_cards) + " | Счёт врага " + str(enemy_score))
	add_enemy_card_on_screen()
	last_enemy_action = Actions.HIT
	state = GameState.PLAYER_TURN
	deferred_next_step()

func stand_enemy():
	last_enemy_action = Actions.STAND
	state = GameState.PLAYER_TURN
	deferred_next_step()

func take_card_player():
	if cards_deck:		
		var card = (cards_deck.pop_back())
		player_cards.append(card)
		player_score = get_score(player_cards)
		logging_box.add_log("Счёт: " + str(player_score) + " | Карты игрока: " + str(player_cards))
		logging_box.add_log("карт в колоде: " + str(cards_deck))
		add_card_on_screen(card)
		last_player_action = Actions.HIT
		state = GameState.ENEMY_TURN
		deferred_next_step()
	else:
		print("колода пуста")

func stand_player():
	logging_box.add_log("Игрок пропустил ход")
	last_player_action = Actions.STAND
	state = GameState.ENEMY_TURN
	deferred_next_step()

func add_card_on_screen(card):
	give_card_button_script.add_card_on_screen(card)

func add_enemy_card_on_screen():
	enemy_cards_container.add_enemy_card_on_screen()

func check_result():
	if game_result == Results.UNDECIDED:
		if player_score == 21 and enemy_score != 21:
			game_result = Results.WIN
		elif player_score == 21 and enemy_score == 21:
			game_result = Results.DRAW
		elif enemy_score == 21 and player_score != 21:
			game_result = Results.LOSS
		elif player_score > 21 and enemy_score < 21:
			game_result = Results.LOSS
		elif enemy_score > 21 and player_score < 21:
			game_result = Results.WIN
		elif last_enemy_action == Actions.STAND and last_player_action == Actions.STAND:
			if abs(player_score - 21) < abs(enemy_score - 21):
				game_result = Results.WIN
			else:
				game_result = Results.LOSS
	else:
		state = GameState.GAME_OVER
		next_step()	
func next_step():
	match state:
		GameState.PLAYER_TURN:
			turn_banner.fade_in_out("player")
			check_result()
			player_turn()
		GameState.ENEMY_TURN:
			turn_banner.fade_in_out("enemy")
			check_result()
			enemy_turn()
		GameState.GAME_OVER:
			game_end(game_result)

func game_end(result):
	end_screen.show_result(result)
	get_parent().add_child(end_screen)
func deferred_next_step():
	call_deferred("next_step")
