class_name BaseCharacter extends CharacterBody3D
@export var heal_amount : float = 10
@export var player_camera : Camera3D
@export_range(0,120) var player_fov: int = 75
@onready var player_animation : AnimationPlayer = $character_5/AnimationPlayer
@export var inventory:  PackedInt64Array
const PLAYER_STATE_LOCATION : String = "res://state/player_state/playersave.cfg"
const ITEM_REFERENCES_JSON : String = "res://assets/item_references.json"
var config = ConfigFile.new()
#COMPONENTS
@export var health_component : HealthComponent
@export var input_component : InputComponent
@export var movement_component : MovementComponent
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_camera.fov = player_fov
var was_captured_before_attack := true

#func _process(delta: float) -> void:
	##var holding_attack := Input.is_action_pressed("attack_start")
	#pass
func _physics_process(delta: float) -> void:
	movement_component.update(self, delta)
func _exit_tree() -> void:
	config.set_value("Player","player_position", transform)
	config.set_value("Player", "player_inventory", inventory)
	config.save("res://state/player_state/playersave.cfg")
	
func _on_health_changed(new_health: float, damage_flag: bool) -> void:
	if damage_flag :
		print(str(new_health) + " Damaged")
	else:
		print(str(new_health) + " Healed")

func _on_heal_keybind_press(heal_type: InputComponent.Heal_Type) -> void:
	if heal_type == 1:
		health_component.heal(heal_amount)
	else:
		health_component.hurt(heal_amount)


func _on_death(has_died: bool) -> void:
	print(has_died)
