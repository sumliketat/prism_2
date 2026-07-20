class_name MovementComponent extends Node

#Notes: Need to find a way for the LSTM to communicate to this component, keep api idea accessible or find out a better way

signal dash_consumed(dash_count : int)

var move_dir : Vector2 = Vector2.ZERO :
	get():
		return move_dir
var jump_pressed : bool = false
const SPEED : float = 4.0
const JUMP_VELOCITY : float = 6.5
const DASH_AMOUNT : float = 220.0
const DASH_TIME : float = 16.0

var dash_count : int = 3
var can_dash : bool = true
var is_dashing : bool = false
var dash_dir : Vector3 = Vector3.UP
var dash_timer : float = 0.0

func update(character: BaseCharacter, delta : float) -> void:
	move_dir = Input.get_vector("move_right","move_left","move_back","move_forw")
	jump_pressed = Input.is_action_pressed("jump")
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	if jump_pressed and character.is_on_floor():
		character.velocity.y = JUMP_VELOCITY
		
	var direction := (character.transform.basis * Vector3(move_dir.x, 0,move_dir.y)).normalized()

	if direction:
		character.velocity.x = direction.x * SPEED
		character.velocity.z = direction.z * SPEED
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, SPEED)
		character.velocity.z = move_toward(character.velocity.z, 0, SPEED)
	dash_logic(delta,  character, direction)
	character.move_and_slide()

func dash_logic(_delta: float, bcharacter : BaseCharacter, direction : Vector3) -> void:
	var input_dir = direction
	if input_dir.x != 0:
		dash_dir.x = input_dir.x
	if can_dash and Input.is_action_just_pressed("dash") and dash_count > 0:
		dash_consumed.emit(dash_count)
		var final_dash_dir : Vector3 = dash_dir
		if input_dir.z != 0 and input_dir.x == 0:
			final_dash_dir.z = 0
		final_dash_dir.y = input_dir.y
		dash_count -= 1
		is_dashing = true
		dash_timer = DASH_TIME
		
		bcharacter.velocity = Vector3(final_dash_dir.x * DASH_AMOUNT, 0, final_dash_dir.z * DASH_AMOUNT)
