extends Node

const save_location := "user://Data/UserData.json"

func _save_data():
	DirAccess.make_dir_absolute("user://Data")

	var contents_to_save := {
		"inventory": GameData.inventory.duplicate(true)
	}

	var file = FileAccess.open(save_location, FileAccess.WRITE)

	if file == null:
		print("ошибка сохранения")
		return

	file.store_var(contents_to_save)
	file.close()

func _load_data():
	if not FileAccess.file_exists(save_location):
		return
	var file = FileAccess.open(save_location, FileAccess.READ)
	var data = file.get_var()
	print(data.duplicate())
	file.close()
	var loaded_data = data.duplicate()
	
	GameData.inventory = loaded_data["inventory"]
	
