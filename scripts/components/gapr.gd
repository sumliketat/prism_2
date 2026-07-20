class_name GAPR extends Node

@export var normal_cell_color: Color = Color(0.2, 0.2, 0.2, 0.5)
@export var crossed_cell_color: Color = Color(0.9, 0.2, 0.2, 0.5)
var attack_active : bool = false
var crossed_cells: Array[int] = []
var _seen_cells :Dictionary= {} # dictionary as set: {"C1": true, ...}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#func _reset_grid_highlight() -> void:
	#for child in GRID.get_children():
		#if child is ColorRect:
			#(child as ColorRect).color = normal_cell_color
#
#func _highlight_cell(cell: Control) -> void:
	#if cell is ColorRect:
		#(cell as ColorRect).color = crossed_cell_color
		#
#func _track_attack_grid_hover() -> void:
	#var mouse_global: Vector2 = get_viewport().get_mouse_position()
	#var local: Vector2 = GRID.get_global_transform_with_canvas().affine_inverse() * mouse_global
#
	#var rect := Rect2(Vector2.ZERO, GRID.size)
	#if not rect.has_point(local):
		#return
#
	#for child in GRID.get_children():
		#if child is Control:
			#var c := child as Control
			#var child_rect := Rect2(c.position, c.size)
			#if child_rect.has_point(local):
				#if not _seen_cells.has(c.name):
					#_seen_cells[c.name] = true
					#crossed_cells.append(c.name)
					#_highlight_cell(c) # <- highlight crossed cell
				#return
#
#var holding_attack := Input.is_action_pressed("attack_start")
#
	#if holding_attack and not attack_active and INV_BACK.visible != true:
		#GAPR.visible = true
		#attack_active = true
		#crossed_cells.clear()
		#_seen_cells.clear()
		#_reset_grid_highlight()
#
		## unlock cursor for UI hover
		#was_captured_before_attack = (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)
		##Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		## optional instead:
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
#
	#if attack_active and holding_attack:
		#_track_attack_grid_hover()
#
	#if attack_active and not holding_attack:
		#attack_active = false
		#GAPR.visible = false
		## lock cursor again for FPS camera
		#if was_captured_before_attack:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#
		#print("Attack crossed cells: ", crossed_cells)
