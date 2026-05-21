extends Node

@export var BoxNode: TextureRect
@export var OutlineShader: Shader
@export var PrizePanel: CanvasLayer

@export var ButtonCassette: Area2D


@export var ButtonStringCassette: ColorRect
@export var ButtonTextCassette: Label

@export var ButtonStringMenu: ColorRect
@export var ButtonTextMenu: Label

@export var ItemTexture: TextureRect
@export var ItemName: Label
@export var ItemAuthor: Label
@export var ItemRarity: Label


var item_rarity: int
var path = "res://Scripts/Items/"
var items: Array[ItemData] = []
var current_rarity_itmes: Array[ItemData] = []
@export var rarity: ItemData.Rarity

var rarity_colors: Dictionary = {
	ItemData.Rarity.GARBAGE: Color(0.451, 0.451, 0.451, 1.0),
	ItemData.Rarity.COMMON: Color(0.961, 0.941, 0.882, 1.0),
	ItemData.Rarity.RARE: Color(0.294, 0.529, 1.0, 1.0),
	ItemData.Rarity.LEGENDARY: Color(1.0, 0.686, 0.255, 1.0)
}

var rarity_names: Dictionary = {
	ItemData.Rarity.GARBAGE: "Мусор",
	ItemData.Rarity.COMMON: "Обычный",
	ItemData.Rarity.RARE: "Редкий",
	ItemData.Rarity.LEGENDARY: "Легендарный"
}


func _ready() -> void:
	BoxNode.material.set_shader_parameter("glow_strength", 0.0)
	
	var dir = DirAccess.open(path)
	for file in dir.get_files():
		if file.ends_with(".tres"):
			items.append(load(path + file))
	choose_prize()
	
	
func pick_random_rarity():
	var total_weight := 0.0
	var weights := []
	for item in items:
		var w = ItemData.rarity_weights[item.rarity]
		weights.append(w)
		total_weight += w
	var r = randf() * total_weight
	var acc := 0.0
	
	for i in range(items.size()):
		acc += weights[i]
		if r <= acc:
			return items[i]
	return items.back()

func choose_prize():
	var prize = pick_random_rarity()
	draw_prize(prize)
	add_item_to_inventory(prize.id, 1)

func draw_prize(item):
	write_labels(item)
	change_box(item.rarity)
	
func write_labels(item):
	ItemName.text = item.name
	ItemAuthor.text = item.author
	ItemRarity.text = rarity_names[item.rarity].to_upper()
	ItemTexture.texture = item.texture

func change_box(rarity):
	BoxNode.material.set_shader_parameter("outline_color", rarity_colors[rarity])
	BoxNode.material.set_shader_parameter("fill_color", rarity_colors[rarity])
	ButtonStringCassette.color = rarity_colors[rarity]
	ButtonStringMenu.color = rarity_colors[rarity]
	if rarity != ItemData.Rarity.GARBAGE:
		ItemRarity.add_theme_color_override("font_color", rarity_colors[rarity])
		BoxNode.material.set_shader_parameter("glow_color", rarity_colors[rarity])
		BoxNode.material.set_shader_parameter("glow_strength", 1.7)
		
	
		
func add_item_to_inventory(item, amount):
	if GameData.inventory.has(item):
		GameData.inventory[item] += amount
	else:
		GameData.inventory[item] = amount
	SaveScript._save_data()
