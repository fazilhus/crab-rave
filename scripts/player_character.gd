class_name PlayerCharacter
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const AIR_RESISTANCE = 2
const STAMINA_MAX = 3

var shoot: Vector3
var bubble: Bubble
var stamina: int = STAMINA_MAX
var is_grabbing : bool = false
var can_grab : bool = false
func _ready():
	SignalBuss._can_grab.connect(_can_grab)
	SignalBuss.bubble_release.connect(on_bubble_release)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
func _can_grab():
	can_grab = true
	
func bubble_logic():
	if Input.is_action_just_pressed("ui_accept") and stamina > 1:
		bubble = Bubble.create(self, stamina)
		stamina -= 1
	if Input.is_action_just_released("ui_accept") and bubble != null:
		bubble.release()
		bubble = null
	if is_on_floor():
		stamina = STAMINA_MAX
	
	velocity += shoot
	shoot.x = move_toward(shoot.x, 0, AIR_RESISTANCE)
	shoot.y = move_toward(shoot.y, 0, AIR_RESISTANCE)
	shoot.z = move_toward(shoot.z, 0, AIR_RESISTANCE)
	
func on_bubble_release(power: float):
	shoot = Vector3(0,1,1) * power
