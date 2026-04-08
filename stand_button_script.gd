extends TextureButton

@onready var card_controller = $"../../CardController"

func _ready():
	#BitMap - класс хранящий монохромные изображения, здесь используется для создания маски
	
	var texture = texture_normal.get_image()
	var bitmap = BitMap.new()
	# все что прозрачнее 0.5 - игнорируется
	bitmap.create_from_image_alpha(texture, 0.5)
	texture_click_mask = bitmap
	
func _on_button_down() -> void:
	card_controller.stand_player()
