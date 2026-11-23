extends CharacterBody2D


const SPEED = 150.0
const JUMP_HEIGHT = 56.0
const GRAVITY_UP = 750.0
const GRAVITY_DOWN = 950.0
const MAX_FALL_SPEED = 334.0
const JUMP_VELOCITY = -sqrt(2.0 * GRAVITY_UP * JUMP_HEIGHT)
var JUMP_CUT = -10000

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		var gravity = GRAVITY_UP if velocity.y < 0 else GRAVITY_DOWN
		if absf(velocity.y) < 60:
			gravity *= 2.0
		velocity.y += gravity * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		JUMP_CUT = velocity.y*0.5
	if velocity.y<JUMP_CUT:
		velocity.y = move_toward(velocity.y,JUMP_CUT,1000*delta)
	if velocity.y>0:
		JUMP_CUT=-10000

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var target_speed = direction * SPEED

	velocity.x = move_toward(
		velocity.x,
		target_speed,
		(1200 if direction != 0 else 2000) * delta
)

	move_and_slide()
