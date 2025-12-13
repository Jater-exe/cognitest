extends MarginContainer

@export var shrink_scale: float = 0.95
@export var anim_duration: float = 0.1

var tween: Tween = null
var center_pivot: Vector2

func _ready() -> void:
	center_pivot = size / 2.0
	pivot_offset = center_pivot
	scale = Vector2.ONE
	var texture_button = get_node_or_null("Objective - Button")
	if texture_button:
		texture_button.button_down.connect(_on_tests_button_down)
		texture_button.button_up.connect(_on_tests_button_up)
	



func _on_tests_button_down() -> void:
	var new_scale = Vector2(shrink_scale, shrink_scale)
	
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "scale", new_scale, anim_duration).set_ease(Tween.EASE_OUT)


func _on_tests_button_up() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, anim_duration).set_ease(Tween.EASE_OUT)

func _on_objective__button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Objective_Control/objective_control.tscn")


func _on_tests__button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/objective_control.tscn")
