extends Control

@export var CardNameLabel: Label
@export var CardContentLabel: Label
@export var BannerTexture: TextureRect
@export var y_offset_ratio: float = 0.1
@export var vboxcontainer: VBoxContainer 

func _ready():
	await get_tree().process_frame
	var center := size / 2
	var y_shift := -size.y * y_offset_ratio

	BannerTexture.pivot_offset = BannerTexture.size / 2
	BannerTexture.position = center - BannerTexture.size / 2 + Vector2(0, y_shift)

	#VBoxContainer.pivot_offset = CardNameLabel.size / 2
	#VBoxContainer.position = center - CardNameLabel.size / 2 + Vector2(0, y_shift)
