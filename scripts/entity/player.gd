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
const COLOR_DASH_USED : Color = Color(0.094, 0.094, 0.094, 0.922)
const COLOR_DASH_AVAIL : Color = Color(0.0, 0.627, 0.627, 1.0)
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


func _on_dash_changed(new_dash_count: int) -> void:
	var i : int = 0
	while i < len(dash_array):
		if i < new_dash_count:
			dash_array[i].set_color(COLOR_DASH_AVAIL)
		else:
			dash_array[i].set_color(COLOR_DASH_USED)
		i += 1
	
 
