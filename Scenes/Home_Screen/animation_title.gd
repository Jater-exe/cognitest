extends AnimationPlayer

func _ready() -> void:
	# Since the script is attached to the AnimationPlayer node,
	# we can call methods on 'self' (the node itself).
	play("Idle_Title_Animation")
