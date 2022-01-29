extends KinematicBody2D


onready var velocity=Vector2(0,0)
onready var Player

var carried=false
func _ready():
	rect=$TileMap.get_used_rect()
	print(rect.size)
	print(rect.position)
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
		
	
func pickup(player):
	carried=true
	Player=player
	set_physics_process(false)

func drop():
	carried=false
	Player=null
	
