extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export var author: String
@export var rarity: Rarity
@export var description: String
@export var abilities: Array[Ability]
@export var texture: Texture2D


enum Rarity {GARBAGE, COMMON, RARE, LEGENDARY}

const rarity_weights = {
	Rarity.GARBAGE: 60,
	Rarity.COMMON: 20,
	Rarity.RARE: 14,
	Rarity.LEGENDARY: 6
}
