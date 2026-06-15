extends Label


func _ready() -> void:
	update_text()

func update_text():
	while len(text)!= 16:
		await get_tree().create_timer(0.5).timeout
		text += "."
	text = "Выход в меню."
	update_text()
