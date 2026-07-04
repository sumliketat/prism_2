extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const PITCH_MIN: float = deg_to_rad(-60)
const PITCH_MAX: float = deg_to_rad(50)
const MOUSE_SENS: float = 0.002
@export var normal_cell_color: Color = Color(0.2, 0.2, 0.2, 0.5)
@export var crossed_cell_color: Color = Color(0.9, 0.2, 0.2, 0.5)
@onready var player_camera = %PlayerCamera
@export_range(0,120) var player_fov: int = 75
@export var yaw: float
@export var pitch: float
@onready var player_animation = %AnimationPlayer

# Your UI path: CharacterBody3D -> GAPR -> GRID -> C1..C9
@onready var GAPR: Control = %GAPR
@onready var GRID: GridContainer = %GAPR/%GRID

@export var attack_active := false
@export var crossed_cells: Array[String] = []
@export var _seen_cells := {} # dictionary as set: {"C1": true, ...}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_camera.fov = player_fov
	GAPR.visible = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		get_tree().quit()

	if attack_active:
		return # don't rotate camera during attack drag

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

	if holding_attack and not attack_active:
		GAPR.visible = true
		attack_active = true
		crossed_cells.clear()
		_seen_cells.clear()
		_reset_grid_highlight()

		# unlock cursor for UI hover
		was_captured_before_attack = (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		# optional instead:
		# Input.mouse_mode = Input.MOUSE_MODE_CONFINED

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
func _reset_grid_highlight() -> void:
	for child in GRID.get_children():
		if child is ColorRect:
			(child as ColorRect).color = normal_cell_color

func _highlight_cell(cell: Control) -> void:
	if cell is ColorRect:
		(cell as ColorRect).color = crossed_cell_color
