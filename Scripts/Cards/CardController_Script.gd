extends Node

var turn := Turn.ENEMY
var BaseCards = load("res://Scripts/Cards/base_cards.gd")
var cards_rate = BaseCards.CARDS
var cards_suit = BaseCards.CARDS_SUITS
var cards_deck = BaseCards.CARDS_DECK52.duplicate()
var end_screen = preload("res://EndScreen.tscn").instantiate()
@export var logging_box: RichTextLabel
@export var hbox_container: HBoxContainer
@export var give_card_button_script: TextureButton
@export var enemy_cards_container: Control
@export var turn_banner: Control
@export var PlayerCardsContainer: HBoxContainer
@export var DeckButton: TextureButton

var max_points = 21

var game_result := Results.UNDECIDED

var enemy_cards:= []
var enemy_score := 0

var player_cards = []
var player_score = 0

enum Actions {HIT, STAND, UNDECIDED}
enum Turn {PLAYER, ENEMY}
enum GameState {PLAYER_TURN, ENEMY_TURN, GAME_OVER}
enum Results {WIN, LOSS, DRAW, UNDECIDED}

var state = GameState.PLAYER_TURN

var last_player_action = Actions.UNDECIDED
var last_enemy_action = Actions.UNDECIDED
	
func _ready():
	GlobalScripts.CardController = self
	GlobalScripts.color_rect_fadeout()
	CardsUiController.hbox_container = PlayerCardsContainer
	CardsUiController.Deck = DeckButton
	CardsUiController.EnemyCardsContainer = enemy_cards_container

	game_result = Results.UNDECIDED
	cards_deck.shuffle()
	choose_turn()
	SaveScript._load_data()
	print(GameData.inventory)
	
	PlayerCardsContainer.add_child(BaseCards.CUSTOMCARD_X2.instantiate())
	PlayerCardsContainer.add_child(BaseCards.CUSTOMCARD_LT.instantiate())
	PlayerCardsContainer.add_child(BaseCards.CUSTOMCARD_M.instantiate())
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
	logging_box.add_log("Ход врага")
	await get_tree().create_timer(randf_range(1.0, 5.0)).timeout
	#запуск монте-карло
	var decision = monte_carlo()
	if decision == Actions.HIT:
		logging_box.add_log("Враг взял карту")
		take_card_enemy()
	else:
		logging_box.add_log("Враг НЕ берет карту")
		stand_enemy()

func monte_carlo() -> int:
	var iterations = 50
	var win_counts = { Actions.HIT: 0, Actions.STAND: 0 }
	for action in [Actions.HIT, Actions.STAND]:
		for i in range(iterations):
			if simulate_game(action):
				win_counts[action] += 1
				
	if win_counts[Actions.STAND] >= win_counts[Actions.HIT]:
		return Actions.STAND
	return Actions.HIT

func simulate_game(starting_action) -> bool:
	var sim_deck = cards_deck.duplicate()
	sim_deck.shuffle()

	var sim_enemy_cards = enemy_cards.duplicate()
	var sim_player_cards = player_cards.duplicate()

	var sim_enemy_score = get_score(sim_enemy_cards)
	var sim_player_score = get_score(sim_player_cards)
	# Стартовые действия бота
	if starting_action == Actions.HIT:
		if sim_deck.is_empty(): return false
		sim_enemy_cards.append(sim_deck.pop_back())
		sim_enemy_score = get_score(sim_enemy_cards)
	if sim_enemy_score > max_points: 
		return false # Бот сразу проиграл от перебора
		
	# Дальнейшие действия бота 
	if starting_action == Actions.HIT:
		while sim_enemy_score < 17:
			if sim_deck.is_empty(): break
			sim_enemy_cards.append(sim_deck.pop_back())
			sim_enemy_score = get_score(sim_enemy_cards)
			if sim_enemy_score > max_points: 
				return false
				
	# Действия игрока
	if last_player_action != Actions.STAND:
		while sim_player_score < 17:
			if sim_deck.is_empty(): break
			sim_player_cards.append(sim_deck.pop_back())
			sim_player_score = get_score(sim_player_cards)
			if sim_player_score > max_points: 
				return true # Игрок перебрал, бот победил
				
	if sim_player_score > max_points: return true
	if sim_enemy_score > max_points: return false
	
	return sim_enemy_score >= sim_player_score
			
func player_turn():
	state = GameState.PLAYER_TURN
	
	
func get_score(cards) -> int:
	var score := 0
	var cards_substr := []
	for card in cards:
		cards_substr.append([(card.substr(1, len(card)))])
		score += cards_rate[(card.substr(1, len(card)))]
	if cards_substr.count(["a"]) > 1:
		score -= ((cards_substr.count(["a"])-1)*10)
	return score
	
func take_card_enemy():
	enemy_cards.append(cards_deck.pop_back())
	enemy_score = get_score(enemy_cards)
	logging_box.on_enemy_take_card_log(str(enemy_cards), str(enemy_score))
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
		logging_box.on_player_take_card_log(str(player_cards), str(player_score))
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
	CardsUiController.add_player_card_on_screen(card)

func add_enemy_card_on_screen():
	CardsUiController.add_enemy_card_on_screen()

func check_result():
	if game_result == Results.UNDECIDED:
		if player_score == max_points and enemy_score != max_points:
			game_result = Results.WIN
		elif player_score == enemy_score and last_enemy_action == Actions.STAND and last_player_action == Actions.STAND:
			game_result = Results.DRAW
		elif enemy_score == max_points and player_score != max_points:
			game_result = Results.LOSS
		elif player_score > max_points and enemy_score < max_points:
			game_result = Results.LOSS
		elif enemy_score > max_points and player_score < max_points:
			game_result = Results.WIN
		elif last_enemy_action == Actions.STAND and last_player_action == Actions.STAND:
			if abs(player_score - max_points) < abs(enemy_score - max_points):
				game_result = Results.WIN
			else:
				game_result = Results.LOSS
func next_step():
	logging_box.cards_in_deck(str(cards_deck))
	match state:
		GameState.PLAYER_TURN:
			turn_banner.fade_in_out("player")
			check_result()
			if game_result == Results.UNDECIDED:
				player_turn()
			else:
				state = GameState.GAME_OVER
				deferred_next_step()	
		GameState.ENEMY_TURN:
			turn_banner.fade_in_out("enemy")
			check_result()
			if game_result == Results.UNDECIDED:
				enemy_turn()
			else:
				state = GameState.GAME_OVER
				deferred_next_step()	
		GameState.GAME_OVER:
			game_end(game_result)

func game_end(result):
	end_screen.PrizePanel.visible = false
	if result == Results.WIN:
		end_screen.PrizePanel.visible = true
		end_screen.PrizePanel.start_prize_panel()
	end_screen.show_result(result)
	get_parent().add_child(end_screen)
func deferred_next_step():
	call_deferred("next_step")
