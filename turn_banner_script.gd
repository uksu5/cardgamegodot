extends Control
@onready var turn_label = $"Turn Label"
@export var transparency := 1.0
@export var interval := 1.0

func fade_in_out(turn):
# скрипт запустится только после готовности ноды
	if not is_node_ready():
		await ready
	match turn:
		"enemy":
			turn_label.set_text("Ход противника")
		"player":
			turn_label.set_text("Ход игрока")
	var tween = create_tween()
	# прозрачность альфа-канала
	modulate.a = 0
	tween.tween_property(self, "modulate:a", transparency, 1.0)
	# пауза
	tween.tween_interval(interval)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
