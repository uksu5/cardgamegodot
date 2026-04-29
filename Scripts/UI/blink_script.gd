extends AnimatedSprite2D


func _ready():
	blink_loop()
func blink_loop():
	while true:
		var wait_time = randf_range(2.0, 10.0)
		await get_tree().create_timer(wait_time).timeout
		play('blinking')
		await animation_finished
		play('idle')
		
