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

onready var right_reflection_raycasts = get_node("RightReflectionRaycasts").get_children()
onready var left_reflection_raycasts = get_node("LeftReflectionRaycasts").get_children()
onready var up_reflection_raycasts = get_node("UpReflectionRaycasts").get_children()
onready var down_reflection_raycasts = get_node("DownReflectionRaycasts").get_children()

onready var reflection_references = [right_reflection, down_reflection, left_reflection, up_reflection]
onready var reflection_raycasts = [right_reflection_raycasts, down_reflection_raycasts, left_reflection_raycasts, up_reflection_raycasts]
onready var DIR_EQUIVALENTS = {Vector2(1, 0): left_reflection_raycasts, Vector2(-1, 0): right_reflection_raycasts, Vector2(0, 1): up_reflection_raycasts, Vector2(0, -1): down_reflection_raycasts}


func update_existence():
	if not get_nearest_mirror(DIR_EQUIVALENTS[past_reflection_dir]) == mirror:
		pop()


func update_position():
	position = source.position + 2 * (mirror.position + mirror.get_center() - source.position).project(past_reflection_dir)


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
	
	source.remove_reflection_reference(self)
	
	player.remove_reflection(self)

func update():
	update_position()
	create_reflections()
	update_reflections()
	update_existence()


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
