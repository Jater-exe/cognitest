extends VBoxContainer


const SAVE_PATH_SUB = "res://JSON/resultados_test.json"
const SAVE_PATH_OBJ = "res://JSON/test_VP.json"

func load_data_from_json() -> Dictionary:
	
	if not FileAccess.file_exists(SAVE_PATH):
		print("No saved file found. Returning empty dictionary.")
		return {}

	var file_sub = FileAccess.open(SAVE_PATH_SUB, FileAccess.READ)
	var file_obj = FileAccess.open(SAVE_PATH_OBJ, FileAccess.READ)
	
	if file_sub and file_obj:
		var json_string_sub: String = file_sub.get_as_text()
		var parse_result_sub: JSON.ParseResult = JSON.parse_string(json_string_sub)
		
		var json_string_obj: String = file_sub.get_as_text()
		var parse_result_obj: JSON.ParseResult = JSON.parse_string(json_string_obj)

		if parse_result_obj and parse_result_sub:
			var loaded_data: Dictionary = parse_result # This dictionary contains both keys
			print("Successfully loaded data.")
			
			return loaded_data
		else:
			print("ERROR: Failed to parse JSON file.")
			return {}
	else:
		print("ERROR: Could not open file for reading.")
		return {}

## --- USAGE EXAMPLE ---
func _ready():
	# Example 1: Save some data
	save_float_to_json(0.42)
	
	# Example 2: Load the saved data
	var loaded_data: Dictionary = load_data_from_json()
	
	if not loaded_data.is_empty():
		var loaded_float: float = loaded_data.get(KEY_FLOAT_VALUE, 0.0)
		var loaded_time: String = loaded_data.get(KEY_TIMESTAMP, "N/A")
		
		print("\n--- Loaded Game State ---")
		print("Float Value: ", loaded_float)
		print("Time Saved:  ", loaded_time)
		print("-------------------------")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
