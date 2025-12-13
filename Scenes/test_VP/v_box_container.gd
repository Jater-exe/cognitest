extends VBoxContainer

const MIN_VALUE: int = 1
const MAX_VALUE: int = 10
const LIST_SIZE: int = 10
const BUTTON_SCENE = preload("res://Scenes/test_VP/NumberButton.tscn") # Assume you have a reusable button scene

@onready var top_row_container: HBoxContainer = $HBoxContainer
@onready var bottom_row_container: HBoxContainer = $HBoxContainer2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_random_seed()
	
	var random_numbers: Array[int] = generate_random_list(MIN_VALUE, MAX_VALUE, LIST_SIZE)
	var half_point = random_numbers.size() / 2
	var top_row_numbers: Array[int] = random_numbers.slice(0, half_point)
	var bottom_row_numbers: Array[int] = random_numbers.slice(half_point, random_numbers.size())
	# Distribute the buttons to the respective containers
	create_numbered_buttons(top_row_numbers, top_row_container)
	create_numbered_buttons(bottom_row_numbers, bottom_row_container)
func initialize_random_seed() -> void:
		randomize()

func generate_random_list(min_val: int, max_val: int, count: int) -> Array[int]:
	var range_size := max_val - min_val + 1
	if count > range_size:
		push_error("Count exceeds unique range")
		return []

	var pool: Array[int] = []
	for i in range(min_val, max_val + 1):
		pool.append(i)

	pool.shuffle()
	return pool.slice(0, count)

func create_numbered_buttons(numbers: Array[int], target_container: HBoxContainer) -> void:
	if not is_instance_valid(target_container):
		print("ERROR: Target container not found!")
		return
		
	for number in numbers:
		var button_instance = BUTTON_SCENE.instantiate()
		
		if button_instance is Button:
			button_instance.text = str(number)
		
		# Add to the container that was passed into the function
		target_container.add_child(button_instance) 
		
		# Connect the button signal (same as before)
		button_instance.pressed.connect(
			Callable(self, "_on_number_button_pressed").bind(number)
		)
func _on_number_button_pressed(number_value: int) -> void:
	# This function is called whenever ANY of the generated buttons is pressed.
	# The 'number_value' argument tells you which number button it was.
	print("Button pressed! The value is: ", number_value)
	
	# Example: Check if the number is even
	if number_value % 2 == 0:
		print("This is an EVEN number.")
	else:
		print("This is an ODD number.")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
