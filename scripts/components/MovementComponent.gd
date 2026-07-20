class_name MovementComponent extends Node

#Notes: Need to find a way for the LSTM to communicate to this component, keep api idea accessible or find out a better way

var move_dir : Vector2 = Vector2.ZERO :
	get():
		return move_dir
var jump_pressed : bool = false
const SPEED = 4.0
const JUMP_VELOCITY = 6.5

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

	character.move_and_slide()
