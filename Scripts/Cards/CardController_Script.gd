extends Node

var turn := Turn.ENEMY
var BaseCards = load("res://Scripts/Cards/base_cards.gd")
var cards_rate = BaseCards.CARDS
var cards_suit = BaseCards.CARDS_SUITS
var cards_deck = BaseCards.CARDS_DECK52.duplicate()
@onready var logging_box = $"../Log label"
@onready var hbox_container = $"../CardsContainer/HBoxContainer"
@onready var give_card_button_script = $"../Deck Buttons/CardsDeckButton"
@onready var enemy_cards_container = $"../EnemyCardsContainer"
@onready var turn_banner = $"../Turn Banner"

var enemy_cards:= []
var enemy_score := 0

var player_score = 0
var player_cards = []

enum Actions {HIT, STAND}
enum Turn {PLAYER, ENEMY}

var last_player_action = ""
var last_enemy_action = ""

var current_turn = ""

func _process(delta):
	if player_score == 21 and enemy_score != 21:
		print("победа игрока")
	elif player_score and enemy_score == 21:
		print("ничья")
	elif enemy_score == 21 and player_score != 21:
		print("победа врага")
	

func _ready():
	cards_deck.shuffle()
	choose_turn()
	
func choose_turn():
	# Случайный выбор хода(игрок/противник)
	randomize()
	turn = [Turn.PLAYER, Turn.ENEMY].pick_random()
	match turn:
		Turn.ENEMY: enemy_turn()
		Turn.PLAYER: player_turn()

func enemy_turn():
	current_turn = "enemy"
	turn_banner.fade_in_out("enemy")
	if len(enemy_cards) == 0:
		take_card_enemy()
		return
	logging_box.add_log("Ход врага")
	await get_tree().create_timer(2.0).timeout
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
	current_turn = "player"
	turn_banner.fade_in_out("player")
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
	last_enemy_action = "hit"
	player_turn()

func stand_enemy():
	last_enemy_action = "stand"
	player_turn()

func take_card_player():
	if cards_deck:		
		var card = (cards_deck.pop_back())
		player_cards.append(card)
		player_score = get_score(player_cards)
		logging_box.add_log("Счёт: " + str(player_score) + " | Карты игрока: " + str(player_cards))
		logging_box.add_log("карт в колоде: " + str(cards_deck))
		add_card_on_screen(card)
		last_player_action = "hit"
		enemy_turn()
	else:
		print("колода пуста")

func stand_player():
	logging_box.add_log("Игрок пропустил ход")
	last_player_action = "stand"
	enemy_turn()

func add_card_on_screen(card):
	give_card_button_script.add_card_on_screen(card)

func add_enemy_card_on_screen():
	enemy_cards_container.add_enemy_card_on_screen()
