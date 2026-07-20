extends Node3D

@export var base_character : BaseCharacter
@onready var player_health : ProgressBar = %PlayerHealth
@export var player_damage_flag: bool
@onready var health_label : Label = %HealthLabel
@onready var camera: Camera3D = %PlayerCamera

func _ready() -> void:
	player_health.set_value_no_signal(100)
	base_character.player_camera = camera

func _on_health_changed(new_health: float, damage_flag: bool) -> void:
	player_health.set_value_no_signal(new_health)
	health_label.text = str(int(new_health))
	player_damage_flag = damage_flag
	
