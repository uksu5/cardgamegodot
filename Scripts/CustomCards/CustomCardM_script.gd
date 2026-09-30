extends CustomCard

func set_names():
	custom_card_name = "Подстава"
	custom_card_description = "Враг берет карту из колоды"


func custom_card_action():
	if GlobalScripts.CardController:
		var CardController = GlobalScripts.CardController
		print("такой-то такой то")
		CardController.take_card_enemy()
		show_card_banner()
		queue_free()
