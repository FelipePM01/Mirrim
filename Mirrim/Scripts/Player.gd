extends KinematicBody2D


var vel = Vector2(0, 0)
var is_carrying = false
var coyote_timed = false
var can_jump = true


onready var floor_detector_left = get_node("Raycasts/FloorDetectorLeft")
onready var floor_detector_right = get_node("Raycasts/FloorDetectorRight")

onready var coyote_timer = get_node("CoyoteTimer")


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	move_process()


func get_input_dir():
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")


func get_move_speed():
	if is_carrying:
		return Global.HEAVY_MOVE_SPEED
	return Global.MOVE_SPEED


func get_acceleration():
	if is_carrying:
		return Global.HEAVY_ACCELERATION
	return Global.ACCELERATION


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
	coyote_timer.start(Global.COYOT)


# Called on coyote time timer timeout. Ends coyote time
func end_coyote_time():
	can_jump = false


# Remembers a jump for a little window so the player can jump while not touching
# the ground
func log_jump():
	jump_logged = true
	log_jump_timer.start()


# Called on log jump timer timeout. Unlogs a jump
func unlog_jump():
	jump_logged = false


func move_process():
	if check_on_floor() and Input.is_action_just_pressed("jump"):
		vel[1] = -get_jump_speed()
	
	var h_aim_vel = get_input_dir() * get_move_speed()
	var v_aim_vel = Global.FALL_SPEED
	
	var new_vel = Vector2(vel[0], vel[1])
	vel = vel.linear_interpolate(Vector2(h_aim_vel, 0), get_acceleration())
	vel = vel.linear_interpolate(Vector2(0, v_aim_vel), get_gravity())
	
	move_and_slide(vel)
