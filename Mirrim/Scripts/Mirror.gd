extends KinematicBody2D


onready var velocity=Vector2(0,0)
onready var Player

var rect
var base_left
var base_right
var base_center

var falling = false
var is_being_carried = false
var carrier = null

var vel = Vector2(0, 0)

var tilemap

func _ready():
	tilemap = $TileMap
	
	rect = tilemap.get_used_rect()
	base_center = (rect.position + Vector2(-rect.size[0] / 2, 0)) * Global.CELL_SIZE
	base_left = rect.position * Global.CELL_SIZE
	base_right = rect.position * Global.CELL_SIZE + Vector2(-rect.size[0] * Global.CELL_SIZE, 0)


func _physics_process(delta):
	if not is_being_carried:
		falling_process()
	else:
		carried_process()


func falling_process():
	if not falling and not is_on_floor():
		falling = true
		
		vel = Vector2(0, -1) * Global.MIRROR_JUMP_SPEED
	
	vel = vel.linear_interpolate(Vector2(0, 1) * Global.FALL_SPEED, Global.GRAVITY)
	vel = move_and_slide(vel)
	
	if falling and is_on_floor():
		falling = false


func carried_process():
	position = carrier.position + Vector2(0, Global.CELL_SIZE / 2) + rect.size.project(Vector2(0, 1)).distance_to(Vector2(0, 0)) * carrier.up_dir * Global.CELL_SIZE


func pickup(entity):
	is_being_carried = true
	carrier = entity
	
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)


func drop():
	var sum_vector = (rect.size.project(Vector2(1, 0)).distance_to(Vector2(0, 0)) / 2 * carrier.dir + rect.size.project(Vector2(0, 1)).distance_to(Vector2(0, 0)) / 2 * carrier.up_dir) * Global.CELL_SIZE
	var aim_pos = carrier.position + carrier.dir * (Global.CELL_SIZE + Global.EXTRA_MIRROR_SPACING) / 2 + sum_vector
	
	var space_state = get_world_2d().direct_space_state
	var shape = RectangleShape2D.new()
	shape.extents = (rect.size * Global.CELL_SIZE + Vector2(Global.EXTRA_MIRROR_SPACING, 0)) / 2
	var request = Physics2DShapeQueryParameters.new()
	request.transform = Transform2D(Vector2(1, 0), Vector2(0, 1), aim_pos)
	request.set_shape(shape)
	
	if space_state.collide_shape(request, 1).size() > 0:
		return false
	
	position = aim_pos
	
	is_being_carried = false
	carrier = null
	
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0, true)
	
	return true


func can_be_picked_up():
	return not is_being_carried


func get_center():
	return Vector2(0, 0)


func get_rect():
	return Rect2(rect.position * Global.CELL_SIZE, rect.size * Global.CELL_SIZE)
