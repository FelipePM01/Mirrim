extends Node


# ------------------------------------------------------------------------------
# VARIABLES
onready var sfx_dict = {"move": $SFX/Move, "stab": $SFX/Stab, "destab": $SFX/Destab, "slip": $SFX/Slip, "hit": $SFX/Hit, "wield": $SFX/Wield, "click": $SFX/Click, "nope": $SFX/Nope}

# ------------------------------------------------------------------------------


func _ready():
	$Music/Music.play()
	$Music/WindLoop.play()


func play_sfx(sfx_name):
	if sfx_dict.has(sfx_name):
		var sfx = sfx_dict[sfx_name]
		
		sfx.seek(0)
		sfx.play()
