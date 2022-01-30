extends Node2D

const MAX_REFLECTIONS = 10

const POSITION_TOLERANCE = 7

const MOVE_SPEED = 90
const HEAVY_MOVE_SPEED = 60

const FALL_SPEED = 250

const MIRROR_JUMP_SPEED = 30
const JUMP_SPEED = 45
const HEAVY_JUMP_SPEED = 38

const ACCELERATION = 0.2
const AIR_ACCELERATION = 0.1
const HEAVY_ACCELERATION = 0.1
const AIR_HEAVY_ACCELERATION = 0.05

const GRAVITY = 0.09
const HELD_GRAVITY = 0.035

const ACTION_RAYCAST_LENGHT = 16

const COYOTE_TIME = 0.07
const LOG_JUMP_TIME = 0.07

const CELL_SIZE = 16
const EXTRA_MIRROR_SPACING = 16

const menu_path = "res://Scenes/Menu.tscn"


const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2

const MAX_RADIUS = 1.3
const MIN_RADIUS = -0.03
const TRANSITION_TIME = 2.0


var current_scene = null
var current_path = ""
var transitioning = false


func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	current_path = current_scene.filename


func goto_scene(path, wipe_point = Vector2(120, 67.5)):
	if not transitioning:
		current_path = path
		
		transitioning = true
		call_deferred("deferred_goto_scene")


func deferred_goto_scene():
	transitioning = false
	
	current_scene.free()
	
	var s = ResourceLoader.load(current_path)
	current_scene = s.instance()
	
	get_tree().get_root().add_child(current_scene)
	
	get_tree().set_current_scene(current_scene)


func restart():
	goto_scene(current_path)


func goto_menu():
	goto_scene(menu_path)

