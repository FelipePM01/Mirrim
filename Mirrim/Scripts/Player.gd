extends KinematicBody2D


var dir = Vector2(1, 0)
var vel = Vector2(0, 0)
var carried = null
var is_carrying = false
var coyote_timed = false
var can_jump = true
var jump_logged = false


onready var floor_detector_left = get_node("Raycasts/FloorDetectorLeft")
onready var floor_detector_right = get_node("Raycasts/FloorDetectorRight")
onready var action_raycast = get_node("Raycasts/ActionRaycast")

onready var coyote_timer = get_node("CoyoteTimer")
onready var log_jump_timer = get_node("LogJumpTimer")


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	dir_process()
	pickup_process()
	move_process()


func get_input_dir():
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")


func get_move_speed():
	if is_carrying:
		return Global.HEAVY_MOVE_SPEED
	return Global.MOVE_SPEED


func get_acceleration():
	if is_carrying:
		if check_on_floor():
			return Global.HEAVY_ACCELERATION
		return Global.AIR_HEAVY_ACCELERATION
	if check_on_floor():
		return Global.ACCELERATION
	return Global.AIR_ACCELERATION


func get_gravity():
	if vel[1] < 0 and Input.is_action_pressed("jump"):
		return Global.HELD_GRAVITY
	return Global.GRAVITY


func get_jump_speed():
	if is_carrying:
		return Global.HEAVY_JUMP_SPEED
	return Global.JUMP_SPEED


func check_on_floor():
	return floor_detector_left.is_colliding() or floor_detector_right.is_colliding()


# Leaves a little window in which the player can jump after leaving the ground
func start_coyote_time():
	coyote_timed = true
	coyote_timer.start(Global.COYOTE_TIME)


# Called on coyote time timer timeout. Ends coyote time
func end_coyote_time():
	can_jump = false


# Remembers a jump for a little window so the player can jump while not touching
# the ground
func log_jump():
	jump_logged = true
	log_jump_timer.start(Global.LOG_JUMP_TIME)


# Called on log jump timer timeout. Unlogs a jump
func unlog_jump():
	jump_logged = false


func get_add_jump_vel():
	if check_on_floor():
		coyote_timed = false
		can_jump = true
	else:
		if not coyote_timed:
			start_coyote_time()
	
	if Input.is_action_just_pressed("jump"):
		log_jump()
	
	if jump_logged and can_jump:
		return Vector2(0, -get_jump_speed())
	return Vector2(0, 0)


func dir_process():
	if vel[0] > 0:
		dir = Vector2(1, 0)
	elif vel[0] < 0:
		dir = Vector2(-1, 0)


func pickup_process():
	if Input.is_action_just_pressed("action"):
		if not is_carrying:
			if check_on_floor() and action_raycast.is_colliding():
				carried = action_raycast.get_collider()
				is_carrying = true
				carried.pickup(self)
		else:
			carried.drop()
			carried = null
			is_carrying = false


func move_process():
	var jump_add_speed = get_jump_speed()
	if check_on_floor() and Input.is_action_just_pressed("jump"):
		vel[1] = -jump_add_speed
	
	var h_vel = Vector2(vel[0], 0).linear_interpolate(get_move_speed() * Vector2(get_input_dir(), 0), get_acceleration())
	var v_vel = Vector2(0, vel[1]).linear_interpolate(Global.FALL_SPEED * Vector2(0, 1), get_gravity()) + get_add_jump_vel()
	
	vel = h_vel + v_vel
	
	move_and_slide(vel)
