extends AnimationPlayer

@onready var animation_player: AnimationPlayer = $AnimationTitle

func _ready() -> void:
	if is_instance_valid(animation_player):
		animation_player.call_deferred("play", "Idle_Title_Animation") 
	else:
		push_error("AnimationPlayer reference is invalid!")
