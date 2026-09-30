extends RichTextLabel

func add_log(text):
	newline()
	add_text(text)

func on_enemy_take_card_log(cards, score):
	add_log("Счёт врага: " + score + " | Карты врага: " + cards)

func on_player_take_card_log(cards, score):
	add_log("Счёт игрока: " + score + " | Карты игрока: " + cards)

func cards_in_deck(cards):
	add_log("Карты в колоде: " + cards)
