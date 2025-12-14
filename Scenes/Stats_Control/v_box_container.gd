extends VBoxContainer


const SAVE_PATH = "user://game_data.json"

func load_data_from_json() -> Dictionary:
	
	if not FileAccess.file_exists(SAVE_PATH):
		print("No saved file found. Returning empty dictionary.")
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file:
		var json_string: String = file.get_as_text()
		var parse_result: JSON.ParseResult = JSON.parse_string(json_string)

		if parse_result:
			var loaded_data: Dictionary = parse_result # This dictionary contains both keys
			print("Successfully loaded data.")
			# Example of extracting the data:
			# print("Loaded Float:", loaded_data.get(KEY_FLOAT_VALUE))
			# print("Last Saved:", loaded_data.get(KEY_TIMESTAMP))
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
