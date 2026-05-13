extends Control

@export var ItemTexture: TextureRect
@export var ItemName: Label
@export var ItemAuthor: Label
@export var ItemRarity: Label


var item_rarity: int
var path = "res://Scripts/Items/"
var items: Array[ItemData] = []
var current_rarity_itmes: Array[ItemData] = []
@export var rarity: ItemData.Rarity


func _ready() -> void:
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

func add_item_to_inventory(item, amount):
	if GameData.inventory.has(item):
		GameData.inventory[item] += amount
	else:
		GameData.inventory[item] = amount
	SaveScript._save_data()

func draw_prize(item):
	ItemName.text = item.name
	ItemAuthor.text = item.author
	ItemRarity.text = str(item.rarity)
	ItemTexture.texture = item.texture
