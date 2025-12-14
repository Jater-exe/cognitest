extends MarginContainer

@export var shrink_scale: float = 0.95
@export var anim_duration: float = 0.1

var tween: Tween = null
var center_pivot: Vector2

func _ready() -> void:
	center_pivot = size / 2.0
	pivot_offset = center_pivot
	scale = Vector2.ONE	
	var texture_button = get_node_or_null("Start - Button")
	if texture_button:
		texture_button.button_down.connect(_on_start__button_button_down)
		texture_button.button_up.connect(_on_start__button_button_up)
	
func _on_start__button_button_down() -> void:
	var new_scale = Vector2(shrink_scale, shrink_scale)
	
	if tween:
		tween.kill()

	tween = create_tween()	
	tween.tween_property(self, "scale", new_scale, anim_duration).set_ease(Tween.EASE_OUT)

func _on_start__button_button_up() -> void:
	if tween:
		tween.kill()	
	
	tween = create_tween()	
	tween.tween_property(self, "scale", Vector2.ONE, anim_duration).set_ease(Tween.EASE_OUT)


func _on_AT__button_pressed() -> void:
	var link = "https://www.youtube.com/watch?v=B_M8eFq2GCA"
	OS.shell_open(link)
	link = "https://www.youtube.com/watch?feature=shared&v=_5HCl5CDA94"
	OS.shell_open(link)
func _on_M__button_pressed() -> void:
	var link = "https://www.youtube.com/watch?v=RExO6edCQYk"
	OS.shell_open(link)
	link = "https://www.youtube.com/watch?v=FJIy-R3Gze4"
	OS.shell_open(link)
	link = "https://www.youtube.com/watch?feature=shared&v=iGTnb1YeRNw"
	OS.shell_open(link)
func _on_VP__button_pressed() -> void:
	var link = "https://www.youtube.com/watch?v=RExO6edCQYk"
	OS.shell_open(link)
	link = "https://www.youtube.com/watch?v=FJIy-R3Gze4"
	OS.shell_open(link)
func _on_FV__button_pressed() -> void:
	var link = "https://www.youtube.com/watch?v=B_M8eFq2GCA"
	OS.shell_open(link)
func _on_FE__button_pressed() -> void:
	var link = "https://www.youtube.com/watch?v=FJIy-R3Gze4"
	OS.shell_open(link)
