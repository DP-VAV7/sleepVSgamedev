extends CharacterBody2D


const SPEED = 133.0
const GRAVITY_UP = 700.0
const GRAVITY_DOWN = 1200.0
const JUMP_VELOCITY = -280.0
const MAX_FALL_SPEED = 334.0
#const JUMP_VELOCITY = -sqrt(2.0 * GRAVITY_UP * JUMP_HEIGHT)


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

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var target_speed = direction * SPEED

	velocity.x = move_toward(
		velocity.x,
		target_speed,
		(800 if direction != 0 else 1400) * delta
)

	move_and_slide()
