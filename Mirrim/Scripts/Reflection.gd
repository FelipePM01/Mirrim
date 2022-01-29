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

onready var right_reflection_raycasts = get_node("Raycasts/RightReflectionRaycasts").get_children()
onready var left_reflection_raycasts = get_node("Raycasts/LeftReflectionRaycasts").get_children()
onready var up_reflection_raycasts = get_node("Raycasts/UpReflectionRaycasts").get_children()
onready var down_reflection_raycasts = get_node("Raycasts/DownReflectionRaycasts").get_children()

onready var reflection_references = [right_reflection, down_reflection, left_reflection, up_reflection]
onready var reflection_raycasts = [right_reflection_raycasts, down_reflection_raycasts, left_reflection_raycasts, up_reflection_raycasts]


func update_existence():
	var rect = mirror.get_rect() 
	var up_left_corner = rect.position
	var down_right_corner = rect.end
	
	if is_reflection_horizontal:
		if position[0] + Global.POSITION_TOLERANCE < up_left_corner[0] or position[0] - Global.POSITION_TOLERANCE > down_right_corner[0]:
			pop()
	else:
		if position[1] + Global.POSITION_TOLERANCE < up_left_corner[1] or position[1] - Global.POSITION_TOLERANCE > down_right_corner[1]:
			pop()


func update_position():
	var reflection_dir = Vector2(1, 0)
	
	if is_reflection_horizontal:
		dir = -source.dir
	else:
		up_dir = -source.up_dir
		reflection_dir = Vector2(0, 1)
	
	position = mirror.position + mirror.get_center() + (mirror.position + mirror.get_center() - source.position).project(reflection_dir)


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
				reflection_references[i] = player.make_reflection(self, mirror, i == 0 or i == 2)


func update_reflections():
	for reflection in reflection_references:
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


func pop():
	for i in reflection_references.size():
		if reflection_references[i]:
			reflection_references[i].pop()
	
	delete_past_reflection_reference()
	
	player.remove_reflection(self)

func update():
	update_position()
	create_reflections()
	update_reflections()


func activate():
	active = true
	update_position()
	show()


func deactivate():
	active = false
	hide()
