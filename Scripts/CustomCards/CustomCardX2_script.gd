extends CustomCard

func custom_card_action():
	if GlobalScripts.CardController:
		GlobalScripts.CardController.max_points = GlobalScripts.CardController.max_points * 2
	print("такой-то такой то")
	GlobalScripts.show_info(GlobalScripts.CardController, "Двойная ставка", "Очки до победы удвоены")
	queue_free()
