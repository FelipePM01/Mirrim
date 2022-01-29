extends KinematicBody2D


var Reflection = preload("res://Scenes/Reflection.tscn")


var active_reflections = 0
var reflections = []
var up_reflection = null
var right_reflection = null
var left_reflection = null
var down_reflection = null

var up_dir = Vector2(0, -1)
var dir = Vector2(1, 0)
var vel = Vector2(0, 0)
var carried = null
var is_carrying = false
var coyote_timed = false
var can_jump = true
var jump_logged = false


onready var parent = get_parent()
onready var floor_detector_left = get_node("Raycasts/FloorDetectorLeft")
onready var floor_detector_right = get_node("Raycasts/FloorDetectorRight")
onready var action_raycast = get_node("Raycasts/ActionRaycast")

onready var coyote_timer = get_node("CoyoteTimer")
onready var log_jump_timer = get_node("LogJumpTimer")

onready var right_reflection_raycasts = get_node("Raycasts/RightReflectionRaycasts").get_children()
onready var left_reflection_raycasts = get_node("Raycasts/LeftReflectionRaycasts").get_children()
onready var up_reflection_raycasts = get_node("Raycasts/UpReflectionRaycasts").get_children()
onready var down_reflection_raycasts = get_node("Raycasts/DownReflectionRaycasts").get_children()

onready var reflection_references = [right_reflection, down_reflection, left_reflection, up_reflection]
onready var reflection_raycasts = [right_reflection_raycasts, down_reflection_raycasts, left_reflection_raycasts, up_reflection_raycasts]


func _ready():
	for i in range(Global.MAX_REFLECTIONS):
		var new_reflection = Reflection.instance()
		new_reflection.player = self
		parent.add_child(new_reflection)
		reflections.append(new_reflection)


func _physics_process(delta):
	dir_process()
	pickup_process()
	move_process()
	reflection_process()


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
			action_raycast.cast_to = dir * Global.ACTION_RAYCAST_LENGHT
			action_raycast.force_raycast_update()
			
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


func get_nearest_mirror(raycast_list):
	var result_collider = null
	
	for raycast in raycast_list:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider.get_collision_layer_bit(1):
				result_collider = collider
				break


func create_reflections():
	for i in range(4):
		if not reflection_references[i]:
			var mirror = get_nearest_mirror(reflection_raycasts[i])
			if mirror:
				reflection_references[i] = make_reflection(self, mirror, i == 0 or i == 2)


func make_reflection(source, mirror, is_reflection_horizontal):
	if active_reflections < Global.MAX_REFLECTIONS:
		reflections[active_reflections].source = source
		reflections[active_reflections].mirror = mirror
		reflections[active_reflections].is_reflection_horizontal = is_reflection_horizontal
		reflections[active_reflections].activate()
		
		active_reflections += 1
		
		return reflections[active_reflections - 1]
	return null


func remove_reflection(reflection):
	reflections.remove(reflections.find(reflection))
	reflections.append(reflection)
	active_reflections -= 1
	
	reflection.deactivate()


func update_reflections():
	for reflection in reflection_references:
		reflection.update()


func reflection_process():
	create_reflections()
	update_reflections()
