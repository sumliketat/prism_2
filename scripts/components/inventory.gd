class_name Inventory extends Node


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#config.load(PLAYER_STATE_LOCATION)
	#inventory = config.get_value("Player", "player_inventory", [])
	#inventory.clear()
	#inventory.append(0)
	#inventory.append(1)
	#inventory.append(2)
	#inventory.append(3)
	#var inventory_scenes : Array = _load_inventory(inventory)
	#var NO_OF_SLOTS = inventory_scenes[0].size()
	#print(NO_OF_SLOTS)
	#for i in NO_OF_SLOTS:
		#print("Entered loop")
		#print(inventory_scenes[1][i])
		#var idx_grid_slot : TextureRect = TextureRect.new()
		#var current_image : Image = Image.load_from_file(inventory_scenes[1][i])
		#var current_texture : ImageTexture = ImageTexture.create_from_image(current_image)
		#var max_size := Vector2(200,200)
		#var tex_size := Vector2(current_texture.get_width(),current_texture.get_height())
		#idx_grid_slot.texture = current_texture
		#var tex_scale :float = min(max_size.x/tex_size.x, max_size.y/tex_size.y, 1.0)
		#idx_grid_slot.custom_maximum_size = tex_size * tex_scale
		#INV_GRID.add_child(idx_grid_slot)
	#
#func _load_inventory(_inventory : PackedInt64Array) -> Array:
	#var item_references = get_json_file_as_dict(ITEM_REFERENCES_JSON)
	#var loaded_inventory: Array
	#var icon_inventory : Array
	#for i in _inventory:
		#for j in item_references:
			#if i == j['id']:
				#loaded_inventory.append(j['scene_path'])
				#icon_inventory.append(j['icon_path'])
			#else:
				#pass
	#return [loaded_inventory,icon_inventory]
	#
##INVENTORY-ADJACENT
#func get_json_file_as_dict(file_path: String) -> Array:
	#var _json = JSON.new()
	#var file_content = FileAccess.get_file_as_string(file_path)
	#var parsed_content = JSON.parse_string(file_content)
	#if parsed_content is Array:
		#return parsed_content
	#else:
		#push_error("Failed to retrieve JSON file: ", file_path)
		#return []
