extends KinematicBody2D


onready var velocity=Vector2(0,0)
onready var Player
onready var tilemap

var rect
var base_left
var base_right
var base_center
var tile_size=16
var carried=false

func _ready():
	rect=$TileMap.get_used_rect()
	base_center=rect.position*tile_size+Vector2(-rect.size.x*tile_size/2,0)
	base_left=rect.position*tile_size
	base_right=rect.position*tile_size+Vector2(-rect.size.x*tile_size,0)
	
func _physics_process(delta):
	if not carried:
		if not is_on_floor():
			velocity.y+=Global.GRAVITY
		if is_on_floor() and velocity.y<0:
			velocity.y=0
		if velocity.y>Global.FALL_SPEED:
			velocity.y=Global.FALL_SPEED
		velocity=move_and_slide(velocity)
	else:
		position=Player.position+Vector2(0,-tile_size/2)+base_center
	
func pickup(player):
	carried=true
	Player=player
	set_collision_layer_bit(0,false)
	set_collision_layer_bit(1,false)
	set_collision_mask_bit(0,false)
func drop():
	carried=false
	var posicao
	if Player.dir.x==1:
		posicao=Player.position+Vector2(+tile_size/2,tile_size/2)+base_left
	else:
		posicao=Player.position+Vector2(-tile_size/2,tile_size/2)+base_right
	
	position = posicao
	var resultado=check_collision(posicao)
	set_collision_layer_bit(0,true)
	set_collision_layer_bit(1,true)
	set_collision_mask_bit(0,true)
	Player=null
	
func get_center():
	return (rect.position+rect.end)/2 * Global.CELL_SIZE
	
func get_rect():
	return Rect2(rect.position * Global.CELL_SIZE, rect.size * Global.CELL_SIZE)
	
func check_collision(posicao):
	pass
