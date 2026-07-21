class_name MovementComponent extends Node

#Notes: Need to find a way for the LSTM to communicate to this component, keep api idea accessible or find out a better way

signal dash_consumed(dash_count : int)
signal dash_changed(new_dash_count: int)
var move_dir : Vector2 = Vector2.ZERO
var jump_pressed : bool = false
const SPEED : float = 4.0
const JUMP_VELOCITY : float = 6.5
const DASH_AMOUNT : float = 220.0
@export var dash_replenish_timer : Timer
var dash_count : int = 3:
	set(value):
		dash_count = clamp(value, 0, 3)
		dash_changed.emit(dash_count)
var can_dash : bool = true
var is_dashing : bool = false
var dash_dir : Vector3 = Vector3.UP
var dash_timer : float = 0.0
var is_dash_replenished : bool = true

func update(character: BaseCharacter, delta : float) -> void:
	move_dir = Input.get_vector("move_right","move_left","move_back","move_forw")
	jump_pressed = Input.is_action_pressed("jump")
	if not character.is_on_floor():
		dash_replenish_timer.paused = true
		character.velocity += character.get_gravity() * delta
	else:
		dash_replenish_timer.paused = false
	if jump_pressed and character.is_on_floor():
		character.velocity.y = JUMP_VELOCITY
		
	var direction : Vector3 = (character.transform.basis * Vector3(move_dir.x, 0,move_dir.y)).normalized()

	if direction:
		character.velocity.x = direction.x * SPEED
		character.velocity.z = direction.z * SPEED
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, SPEED)
		character.velocity.z = move_toward(character.velocity.z, 0, SPEED)
	dash_logic(delta,  character, direction)
	character.move_and_slide()

func dash_logic(_delta: float, bcharacter : BaseCharacter, direction : Vector3) -> void:
	is_dash_replenished =  false
	var input_dir = direction
	if input_dir.x != 0:
		dash_dir.x = input_dir.x
	if Input.is_action_just_pressed("dash") and dash_count > 0:
		dash_replenish_timer.start()
		dash_consumed.emit(dash_count)
		print("Dash Consumed")
		var final_dash_dir : Vector3 = dash_dir
		if direction.length() > 0.001:
			final_dash_dir  = direction.normalized()
		final_dash_dir.y = input_dir.y
		
		var dash_vel = final_dash_dir * DASH_AMOUNT
		dash_vel.y = 0
		dash_vel.x = clamp(dash_vel.x, -350.0, 350.0)
		dash_vel.z = clamp(dash_vel.z, -350.0, 350.0)
		bcharacter.velocity.x = dash_vel.x
		bcharacter.velocity.z = dash_vel.z
		dash_count -= 1
		is_dashing = true
	if dash_count < 3 and !is_dash_replenished:
		dash_replenish_timer.start()
func _on_dash_replenish() -> void:
	dash_count += 1
	is_dash_replenished = true
	print("Dash Replenished")
