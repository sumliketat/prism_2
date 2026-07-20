class_name InputComponent extends Node

#Notes: Future functionality would be adding the ability to change keybinds on runtime and saving keybinds to save data


signal health_keybind_pressed(heal_type : Heal_Type)
enum Heal_Type {HURT, HEAL} 
const PITCH_MIN: float = deg_to_rad(-60)
const PITCH_MAX: float = deg_to_rad(40)
const MOUSE_SENS: float = 0.002
@export var yaw: float
@export var pitch: float
@export var base_character: BaseCharacter
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	yaw -= event.relative.x * MOUSE_SENS
	pitch -= event.relative.y * MOUSE_SENS
	pitch = clamp(pitch,PITCH_MIN,PITCH_MAX)
	_character.rotation.y = yaw
	_character.player_camera.rotation.x = pitch
	_character.player_camera.rotation.z = 0.0
