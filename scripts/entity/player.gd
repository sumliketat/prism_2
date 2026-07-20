extends Node3D

@export var base_character : BaseCharacter
@onready var player_health : ProgressBar = %PlayerHealth
@export var player_damage_flag: bool
@onready var health_label : Label = %HealthLabel
@onready var camera: Camera3D = %PlayerCamera
@onready var death_text: Label = %DeathText
@onready var dash_count_1: ColorRect = %DashCount1
@onready var dash_count_2: ColorRect = %DashCount2
@onready var dash_count_3: ColorRect = %DashCount3
var dash_array : Array[ColorRect]
func _ready() -> void:
	player_health.set_value_no_signal(100)
	base_character.player_camera = camera
	death_text.visible = false
	dash_array = [dash_count_1, dash_count_2, dash_count_3]

func _on_health_changed(new_health: float, damage_flag: bool) -> void:
	if new_health > 0:
		death_text.visible = false
	player_health.set_value_no_signal(new_health)
	health_label.text = str(int(new_health))
	player_damage_flag = damage_flag
	


func _on_death(has_died: bool) -> void:
	if has_died:
		death_text.visible = true


func _on_dash_consumed(dash_count: int) -> void:
	dash_array[dash_count-1].set_color(Color(0.08, 0.08, 0.08, 0.9))
