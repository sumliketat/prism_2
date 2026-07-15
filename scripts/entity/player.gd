extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const PITCH_MIN: float = deg_to_rad(-60)
const PITCH_MAX: float = deg_to_rad(40)
const MOUSE_SENS: float = 0.002
@export var normal_cell_color: Color = Color(0.2, 0.2, 0.2, 0.5)
@export var crossed_cell_color: Color = Color(0.9, 0.2, 0.2, 0.5)
@onready var player_camera = %PlayerCamera
@export_range(0,120) var player_fov: int = 75
@export var yaw: float
@export var pitch: float
@onready var player_animation = %AnimationPlayer
const WEAPON_SLOTS: int = 5
@export var equipped_item : Variant

@export var inventory:  PackedInt64Array
const PLAYER_STATE_LOCATION : String = "res://state/player_state/playersave.cfg"
const ITEM_REFERENCES_JSON : String = "res://assets/item_references.json"
var config = ConfigFile.new()

@onready var GAPR: Control = %GAPR
@onready var GRID: GridContainer = %GAPR/%GRID
@onready var INV_BACK: Panel = %InventoryBackground
@onready var INV_GRID: GridContainer = %InventoryGrid

@export var attack_active := false
@export var crossed_cells: Array[String] = []
@export var _seen_cells := {} # dictionary as set: {"C1": true, ...}



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_camera.fov = player_fov
	GAPR.visible = false
	INV_BACK.visible=false
	config.load(PLAYER_STATE_LOCATION)
	inventory = config.get_value("Player", "player_inventory", [])
	inventory.clear()
	inventory.append(0)
	inventory.append(1)
	inventory.append(2)
	inventory.append(3)
	var inventory_scenes : Array = _load_inventory(inventory)
	var NO_OF_SLOTS = inventory_scenes[0].size()
	print(NO_OF_SLOTS)
	for i in NO_OF_SLOTS:
		print("Entered loop")
		print(inventory_scenes[1][i])
		var idx_grid_slot : TextureRect = TextureRect.new()
		var current_image : Image = Image.load_from_file(inventory_scenes[1][i])
		var current_texture : ImageTexture = ImageTexture.create_from_image(current_image)
		var max_size := Vector2(200,200)
		var tex_size := Vector2(current_texture.get_width(),current_texture.get_height())
		idx_grid_slot.texture = current_texture
		var tex_scale :float = min(max_size.x/tex_size.x, max_size.y/tex_size.y, 1.0)
		idx_grid_slot.custom_maximum_size = tex_size * tex_scale
		INV_GRID.add_child(idx_grid_slot)
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		get_tree().quit()
	if event.is_action_pressed("open_inventory"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		INV_BACK.visible = true
	if event.is_action_pressed("close_inventory"):
		INV_BACK.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if attack_active:
		return # dont rotate camera during attack drag

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * MOUSE_SENS
		pitch -= event.relative.y * MOUSE_SENS
		pitch = clamp(pitch, PITCH_MIN, PITCH_MAX)
		rotation.y = yaw
		player_camera.rotation.x = pitch
		player_camera.rotation.z = 0.0
var was_captured_before_attack := true

func _process(_delta: float) -> void:
	var holding_attack := Input.is_action_pressed("attack_start")

	if holding_attack and not attack_active and INV_BACK.visible != true:
		GAPR.visible = true
		attack_active = true
		crossed_cells.clear()
		_seen_cells.clear()
		_reset_grid_highlight()

		# unlock cursor for UI hover
		was_captured_before_attack = (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		# optional instead:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	if attack_active and holding_attack:
		_track_attack_grid_hover()

	if attack_active and not holding_attack:
		attack_active = false
		GAPR.visible = false
		# lock cursor again for FPS camera
		if was_captured_before_attack:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		print("Attack crossed cells: ", crossed_cells)
func _track_attack_grid_hover() -> void:
	var mouse_global: Vector2 = get_viewport().get_mouse_position()
	var local: Vector2 = GRID.get_global_transform_with_canvas().affine_inverse() * mouse_global

	var rect := Rect2(Vector2.ZERO, GRID.size)
	if not rect.has_point(local):
		return

	for child in GRID.get_children():
		if child is Control:
			var c := child as Control
			var child_rect := Rect2(c.position, c.size)
			if child_rect.has_point(local):
				if not _seen_cells.has(c.name):
					_seen_cells[c.name] = true
					crossed_cells.append(c.name)
					_highlight_cell(c) # <- highlight crossed cell
				return

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_right", "move_left", "move_back", "move_forw")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	var is_animating := input_dir.length() > 0.0
	if is_animating:
		if player_animation.current_animation != "Walk":
			player_animation.play("Walk", -1, 3.0)
	else:
		if player_animation.current_animation != "Idle":
			player_animation.play("Idle", -1, 0.5)

	move_and_slide()
func _exit_tree() -> void:
	config.set_value("Player","player_position", transform)
	config.set_value("Player", "player_inventory", inventory)
	config.save("res://state/player_state/playersave.cfg")

func _reset_grid_highlight() -> void:
	for child in GRID.get_children():
		if child is ColorRect:
			(child as ColorRect).color = normal_cell_color

func _highlight_cell(cell: Control) -> void:
	if cell is ColorRect:
		(cell as ColorRect).color = crossed_cell_color
func _load_inventory(_inventory : PackedInt64Array) -> Array:
	var item_references = get_json_file_as_dict(ITEM_REFERENCES_JSON)
	var loaded_inventory: Array
	var icon_inventory : Array
	for i in inventory:
		for j in item_references:
			if i == j['id']:
				loaded_inventory.append(j['scene_path'])
				icon_inventory.append(j['icon_path'])
			else:
				pass
	return [loaded_inventory,icon_inventory]
	
func get_json_file_as_dict(file_path: String) -> Array:
	var _json = JSON.new()
	var file_content = FileAccess.get_file_as_string(file_path)
	var parsed_content = JSON.parse_string(file_content)
	if parsed_content is Array:
		return parsed_content
	else:
		push_error("Failed to retrieve JSON file: ", file_path)
		return []
