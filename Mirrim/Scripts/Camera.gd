extends Camera2D


const LERP_WEIGHT = 0.1
const ROTATION_TIME = 1.0

const SHAKE_MIN = 0.1
const SHAKE_SMALL = 0.2
const SHAKE_MEDIUM = 0.5
const SHAKE_BIG = 0.8

const DECAY = 0.8
const MAX_OFFSET = Vector2(32, 18)
const MAX_ROLL = 0.15
const TRAUMA_POWER = 2

var EFFECTIVE_LERP_WEIGHT

var trauma = 0.0


var aim_rot = 0
var base_rotation = 0


onready var noise = OpenSimplexNoise.new()
var noise_y = 0

func _ready():
	if Global.rotation_enabled:
		EFFECTIVE_LERP_WEIGHT = LERP_WEIGHT
	else:
		EFFECTIVE_LERP_WEIGHT = 0
	
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	
	play_anim("grapple")


func _process(delta):
	base_rotation = lerp_angle(base_rotation, aim_rot, EFFECTIVE_LERP_WEIGHT)
	
	if trauma:
		trauma = max(trauma - DECAY * delta, 0)
		shake()
	else:
		rotation = base_rotation


func add_trauma(amount):
	trauma = min(trauma + amount * (1.0 - trauma), 1.0)


func shake():
	var amount = pow(trauma, TRAUMA_POWER)
	
	noise_y += 1
	
	rotation = base_rotation + MAX_ROLL * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset[0] = MAX_OFFSET[0] * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset[1] = MAX_OFFSET[1] * amount * noise.get_noise_2d(noise.seed * 3, noise_y)


func play_anim(animation):
	animation_player.play(animation)
