extends Sprite

var player = null
var source = null
var mirror = null
var is_reflection_horizontal = false

var up_reflection = null
var right_reflection = null
var left_reflection = null
var down_reflection = null

var past_reflection_dir
var carried = null
var active = false
var is_carrying = false
var up_dir = Vector2(0, -1)
var dir = Vector2(1, 0)

onready var action_raycast = $ActionRaycast

onready var animation_player = $AnimationPlayer

onready var right_reflection_raycasts = get_node("RightReflectionRaycasts").get_children()
onready var left_reflection_raycasts = get_node("LeftReflectionRaycasts").get_children()
onready var up_reflection_raycasts = get_node("UpReflectionRaycasts").get_children()
onready var down_reflection_raycasts = get_node("DownReflectionRaycasts").get_children()

onready var reflection_references = [right_reflection, down_reflection, left_reflection, up_reflection]
onready var reflection_raycasts = [right_reflection_raycasts, down_reflection_raycasts, left_reflection_raycasts, up_reflection_raycasts]
onready var DIR_EQUIVALENTS = {Vector2(1, 0): left_reflection_raycasts, Vector2(-1, 0): right_reflection_raycasts, Vector2(0, 1): up_reflection_raycasts, Vector2(0, -1): down_reflection_raycasts}


func update_existence():
	if not (get_nearest_mirror(DIR_EQUIVALENTS[past_reflection_dir]) == mirror and get_nearest_mirror(source.DIR_EQUIVALENTS[-past_reflection_dir]) == mirror):
		pop()


func update_position():
	position = source.position + 2 * (mirror.position + mirror.get_center() - source.position).project(past_reflection_dir)
	
	if is_reflection_horizontal:
		dir = -source.dir


func get_nearest_mirror(raycast_list):
	var result_collider = null
	
	for raycast in raycast_list:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider.get_collision_layer_bit(1):
				result_collider = collider
				break
	
	return result_collider


func create_reflections():
	for i in range(4):
		if not reflection_references[i] and DIR_EQUIVALENTS[past_reflection_dir] != reflection_raycasts[i]:
			var mirror = get_nearest_mirror(reflection_raycasts[i])
			if mirror:
				reflection_references[i] = player.make_reflection(self, mirror, i == 0 or i == 2)


func update_reflections():
	for reflection in reflection_references:
		if reflection:
			reflection.update()


func delete_past_reflection_reference():
	match past_reflection_dir:
		Vector2(1, 0):
			source.right_reflection = null
		Vector2(0, -1):
			source.up_reflection = null
		Vector2(-1, 0):
			source.left_reflection = null
		Vector2(0 , 1):
			source.down_reflection = null


func remove_reflection_reference(reflection):
	for i in range(4):
		if reflection_references[i] == reflection:
			reflection_references[i] = null
			break


func pop():
	for i in reflection_references.size():
		if reflection_references[i]:
			reflection_references[i].pop()
	
	if is_carrying:
		force_drop()
	
	source.remove_reflection_reference(self)
	
	player.remove_reflection(self)

func update():
	update_position()
	update_animation()
	create_reflections()
	update_reflections()
	update_existence()


func force_drop():
	carried.drop_in_place()
	
	carried = null
	is_carrying = false


func try_pickup():
	if not is_carrying:
		action_raycast.cast_to = dir * Global.ACTION_RAYCAST_LENGHT
		action_raycast.force_raycast_update()
		
		if action_raycast.is_colliding():
			var collider = action_raycast.get_collider()
			if collider.can_be_picked_up():
				carried = action_raycast.get_collider()
				is_carrying = true
				carried.pickup(self)
	else:
		if carried.drop():
			carried = null
			is_carrying = false


func pickup():
	try_pickup()
	if not is_carrying:
		for i in range(4):
			if reflection_references[i]:
				reflection_references[i].pickup()


func activate():
	active = true
	update_position()
	for raycast_list in reflection_raycasts:
		for raycast in raycast_list:
			raycast.force_raycast_update()
	
	show()


func deactivate():
	active = false
	hide()


func flip_process():
	if dir == Vector2(1, 0):
		flip_h = false
	else:
		flip_h = true
	
	if up_dir == Vector2(0, -1):
		flip_v = false
	else:
		flip_v = true


func get_true_animation_name(anim):
	if is_carrying:
		return "carry_" + anim
	return anim


func check_on_floor():
	return source.check_on_floor()


func get_vel():
	var vel = source.get_vel()
	
	if is_reflection_horizontal:
		vel[0] = -vel[0]
	else:
		vel[1] = -vel[1]
	
	return vel


func update_animation():
	flip_process()
	
	if check_on_floor():
		if get_vel()[0] != 0:
			animation_player.play(get_true_animation_name("move"))
		else:
			animation_player.play(get_true_animation_name("idle"))
	else:
		if get_vel().dot(up_dir) > 0:
			animation_player.play(get_true_animation_name("jump"))
		else:
			animation_player.play(get_true_animation_name("fall"))
