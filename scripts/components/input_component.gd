class_name InputComponent extends Node

signal health_keybind_pressed(heal_type : Heal_Type)
enum Heal_Type {HURT, HEAL} 
var move_dir : Vector2 = Vector2.ZERO :
	get():
		return move_dir
var jump_pressed : bool = false
@export var base_character: BaseCharacter
#signal change_health(value : float, damage_flag: bool)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update() -> void:
	move_dir = Input.get_vector("move_right","move_left","move_back","move_forw")
	jump_pressed = Input.is_action_pressed("jump")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		get_tree().quit()
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		update_camera(event, base_character)
	if event.is_action_pressed("hurt(debug)"):
		health_keybind_pressed.emit(Heal_Type.HURT)
	if event.is_action_pressed("heal(debug)"):
		health_keybind_pressed.emit(Heal_Type.HEAL)

func  update_camera(event : InputEvent,_character: BaseCharacter) -> void:
	_character.yaw -= event.relative.x * _character.MOUSE_SENS
	_character.pitch -= event.relative.y * _character.MOUSE_SENS
	_character.pitch = clamp(_character.pitch, _character.PITCH_MIN, _character.PITCH_MAX)
	_character.rotation.y = _character.yaw
	_character.player_camera.rotation.x = _character.pitch
	_character.player_camera.rotation.z = 0.0
