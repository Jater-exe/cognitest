extends VBoxContainer

const MIN_VALUE: int = 1
const MAX_VALUE: int = 10
const LIST_SIZE: int = 10
const BUTTON_SCENE = preload("res://Scenes/test_VP/NumberButton.tscn") # Assume you have a reusable button scene
const SAVE_PATH = "res://JSON/test_VP.json"
const KEY_FLOAT_VALUE = "time_delay"
# New key for the timestamp
const KEY_TIMESTAMP = "test_time"
const KEY_RESULT = "test_result"

@onready var top_row_container: HBoxContainer = $HBoxContainer
@onready var bottom_row_container: HBoxContainer = $HBoxContainer2
var last_num: int = 0
var total_wait_time: float = 0
var current_wait_time: float = 0
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
		var button_label: Label = button_instance.find_child("NumLabel")
		button_label.text = str(number)
		if button_instance is Button:
			button_instance.text = str(number)
		
		# Add to the container that was passed into the function
		target_container.add_child(button_instance) 
		
		# Connect the button signal (same as before)
		button_instance.pressed.connect(
			Callable(self, "_on_number_button_pressed").bind(number)
		)
func _on_number_button_pressed(number_value: int) -> void:
	print(number_value)
	print(total_wait_time)
	if number_value == last_num+1:
		last_num = number_value
		total_wait_time += current_wait_time
		current_wait_time = 0
		if number_value == 10:
			save_float_to_json(total_wait_time)
			get_tree().change_scene_to_file("res://Scenes/test_VP/test_VP_control.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_wait_time += delta



#GUARDAT DADES

func _cargar_base_datos() -> Dictionary:
	# Si el archivo no existe, devolvemos una estructura vacía inicializada
	if not FileAccess.file_exists(SAVE_PATH):
		return { "registros": [] } # Equivalente a inicializar el struct base
	
	# Leemos el archivo
	var archivo = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var contenido_texto = archivo.get_as_text()
	archivo.close()
	
	# Parseamos JSON
	var json = JSON.new()
	var error = json.parse(contenido_texto)
	
	if error == OK:
		var datos = json.data
		# Validación defensiva: Asegurarnos de que tiene la key "registros"
		if not datos.has("registros"):
			datos["registros"] = []
		return datos
	else:
		push_error("JSON Corrupto. Reiniciando DB.")
		return { "registros": [] }

func _guardar_en_disco(datos: Dictionary):
	var archivo = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if archivo:
		# Convertimos el diccionario completo a texto
		var json_string = JSON.stringify(datos, "\t")
		archivo.store_string(json_string)
		archivo.close()
		print("Base de datos actualizada con nuevo registro en user://resultados_test.json.")


func save_float_to_json(wait_time: float) -> void:
	var resultat_bool
	if(wait_time>9.00):
		resultat_bool = "not_pass"
	else:
		resultat_bool = "pass"
	
	var db_completa = _cargar_base_datos()
	
	var current_time_string: String = Time.get_datetime_string_from_system()
	var save_data: Dictionary = {
		KEY_TIMESTAMP: current_time_string,
		KEY_RESULT: resultat_bool,
		KEY_FLOAT_VALUE: wait_time
	}
	# 4. Añadir el nuevo registro a la lista
	db_completa["registros"].append(save_data)
	
	# 5. Guardar todo el archivo de nuevo
	_guardar_en_disco(db_completa)
