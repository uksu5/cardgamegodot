extends CustomCard

func custom_card_action():
	if GlobalScripts.CardController:
		var CardController = GlobalScripts.CardController
		print("такой-то такой то")
		GlobalScripts.show_info(CardController, "Взгляд сквозь", "Очки врага: %d" % CardController.get_score(CardController.enemy_cards))
		queue_free()
