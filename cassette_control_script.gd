extends Control

var scene_owner

var path = "res://Scripts/Items/"
var items: Array[ItemData] = []
var current_rarity_itmes: Array[ItemData] = []
var items_in_inventory = []
@export var grid_container: GridContainer

@export var PrizeBox: TextureRect
@export var DescriptionBox: TextureRect

@export var PrizeTexture: TextureRect
@export var ItemName: Label
@export var ItemAuthor: Label
@export var ItemRarity: Label

@export var ItemDescription: RichTextLabel

var rarity_names: Dictionary = {
	ItemData.Rarity.GARBAGE: "мусор",
	ItemData.Rarity.COMMON: "обычный",
	ItemData.Rarity.RARE: "редкий",
	ItemData.Rarity.LEGENDARY: "легендарный"
}

var rarity_colors: Dictionary = {
	ItemData.Rarity.GARBAGE: Color(0.451, 0.451, 0.451, 1.0),
	ItemData.Rarity.COMMON: Color(0.961, 0.941, 0.882, 1.0),
	ItemData.Rarity.RARE: Color(0.294, 0.529, 1.0, 1.0),
	ItemData.Rarity.LEGENDARY: Color(1.0, 0.686, 0.255, 1.0)
}

func _ready() -> void:
	PrizeBox.visible = false


	SaveScript._load_data()
	var inventory = GameData.inventory
	for item in inventory:
		var count = inventory[item]
		for i in range(count):
			items_in_inventory.append(item)
	
	GlobalScripts.load_resources_from_dir(path, items)
	get_items()

func get_items():
	for inventory_item in items_in_inventory:
		for item in items:
			if item.id == inventory_item:
				draw_item(item)

func draw_item(item):
	var item_scene = preload("res://ScreenItem.tscn")
	var screen_item = item_scene.instantiate()
	screen_item.owner_scene = self
	screen_item.init(item)
	grid_container.add_child(screen_item)
	
func write_item_data(item):
	ItemRarity.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	PrizeTexture.texture = item.texture
	ItemName.text = item.name
	ItemAuthor.text = item.author
	ItemRarity.text = rarity_names[item.rarity]
	ItemDescription.text = item.description
	PrizeBox.texture = load("res://baked_boxes/box_%s.png" % str(item.rarity))
	DescriptionBox.texture = load("res://baked_boxes/box_%s.png" % str(item.rarity))
	if item.rarity != 0:
		ItemRarity.add_theme_color_override("font_color", rarity_colors[item.rarity])
	
	GlobalScripts.show_with_fadein(PrizeBox, 0.5)
	


func _on_to_menu_button_button_down() -> void:
	GlobalScripts.hide_with_fadeout(self, 0.5)
	GlobalScripts.show_with_fadein(scene_owner.MainMenuScreen, 0.5)
	PrizeBox.hide()
