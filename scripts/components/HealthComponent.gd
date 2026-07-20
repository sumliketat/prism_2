class_name HealthComponent extends Node

signal health_changed(new_health : float, damage_flag: bool)
signal has_died(has_died: bool)
@export var health : float = 100:
	get():
		return health
	set(value):
		if value > 0:
			if value < health:
				health = clamp(value, 0, 100)
				health_changed.emit(health, 1)
			else:
				health = clamp(value, 0, 100)
				health_changed.emit(health, 0)
		elif value == 0:
			has_died.emit(true)
		else :
			push_error("Health Value < 0")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func hurt(damage : float):
	health -= damage

func heal(amount: float):
	health += amount
