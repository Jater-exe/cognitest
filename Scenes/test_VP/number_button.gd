extends TextureButton

@export var shrink_scale: float = 0.95
@export var anim_duration: float = 0.1
const START_TEXTURE = preload("res://Textures/normal_button.png")
const PAUSE_TEXTURE = preload("res://Textures/disabled_button.png")
var is_disabled: bool = false

var tween: Tween = null
var center_pivot: Vector2

func _ready() -> void:
	center_pivot = size / 2.0
	pivot_offset = center_pivot
	scale = Vector2.ONE	
	var texture_button = get_node_or_null("NumberButton")
	if texture_button:
		texture_button.button_down.connect(_on_texture_button_down)
		texture_button.button_up.connect(_on_texture_button_up)
		texture_button = START_TEXTURE
	
func _on_texture_button_down() -> void:
	if not is_disabled:
		var new_scale = Vector2(shrink_scale, shrink_scale)
		
		if tween:
			tween.kill()

		tween = create_tween()	
		tween.tween_property(self, "scale", new_scale, anim_duration).set_ease(Tween.EASE_OUT)

func _on_texture_button_up() -> void:
	if not is_disabled:
		if tween:
			tween.kill()	
		
		tween = create_tween()	
		tween.tween_property(self, "scale", Vector2.ONE, anim_duration).set_ease(Tween.EASE_OUT)
		
		is_disabled = true
		texture_normal = PAUSE_TEXTURE
