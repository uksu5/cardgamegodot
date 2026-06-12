extends Control

@export var box: TextureRect

var rarity_colors = {
	ItemData.Rarity.GARBAGE: Color(0.451, 0.451, 0.451, 1.0),
	ItemData.Rarity.COMMON: Color(0.961, 0.941, 0.882, 1.0),
	ItemData.Rarity.RARE: Color(0.294, 0.529, 1.0, 1.0),
	ItemData.Rarity.LEGENDARY: Color(1.0, 0.686, 0.255, 1.0)
}

var vp: SubViewport

func _ready():
	await get_tree().process_frame
	await bake_all()
	get_tree().quit()


func bake_all():
	DirAccess.make_dir_recursive_absolute("res://baked_boxes")

	for rarity in rarity_colors.keys():
		await bake_one(rarity)


func bake_one(rarity):

	# ----------------------------
	# создаём SubViewport
	# ----------------------------
	if vp:
		vp.queue_free()

	vp = SubViewport.new()
	vp.size = box.size
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE

	add_child(vp)

	# ----------------------------
	# копируем box внутрь viewport
	# ----------------------------
	var box_copy = box.duplicate()
	vp.add_child(box_copy)

	# важно: чтобы он заполнил viewport 1:1
	box_copy.position = Vector2.ZERO
	box_copy.anchor_left = 0
	box_copy.anchor_top = 0
	box_copy.anchor_right = 1
	box_copy.anchor_bottom = 1
	box_copy.offset_left = 0
	box_copy.offset_top = 0
	box_copy.offset_right = 0
	box_copy.offset_bottom = 0

	# ----------------------------
	# применяем материалы
	# ----------------------------
	var mat := box_copy.material.duplicate() as ShaderMaterial
	box_copy.material = mat

	var col = rarity_colors[rarity]

	mat.set_shader_parameter("outline_color", col)
	mat.set_shader_parameter("fill_color", col)
	mat.set_shader_parameter("glow_color", col)
	mat.set_shader_parameter("glow_strength", 0)
	if rarity != 0:
		mat.set_shader_parameter("glow_strength", 2.0)

	# ----------------------------
	# ждём рендер
	# ----------------------------
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

	# ----------------------------
	# получаем image
	# ----------------------------
	var img := vp.get_texture().get_image()

	# ----------------------------
	# сохраняем
	# ----------------------------
	var name := str(rarity)
	img.save_png("res://baked_boxes/box_%s.png" % name)

	# ----------------------------
	# cleanup
	# ----------------------------
	vp.queue_free()
	vp = null
