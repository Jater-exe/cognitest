extends VBoxContainer # O el tipo de nodo que sea tu raíz

# --- DATOS ---
# Aquí escribes todas tus preguntas
var lista_preguntas = [
	"He anat a un lloc de l’habitació i, quan hi he arribat, no he recordat què hi anava a fer",
	"He trigat més del normal a fer una activitat que abans feia més ràpid",
	"Volia dir una paraula i no m’ha sortit, o n’he dit una altra sense voler",
	"Quan estava parlant amb algú, he perdut el fil de la conversa",
	"M’han preguntat per una cosa que m’havien dit fa poc i no me n’he recordat",
	"He tingut problemes per recordar informació que ja sabia prèviament",
	"He tingut problemes per prendre una decisió que abans no m’hauria costat",
	"He tingut dificultats per planificar el meu dia",	
]

# --- VARIABLES DE ESTADO ---
var indice_pregunta_actual = 0
var respuestas_guardadas = [] # Aquí se irán guardando los "SI" y "NO"

# --- REFERENCIAS A NODOS ---
# Ajusta estas rutas para que coincidan con tu árbol de escena
@onready var label_pregunta = $Label
@onready var boton_no = $MarginContainer/HBoxContainer/BOTONO 
@onready var boton_si = $MarginContainer/HBoxContainer/BOTOSI

# Definimos la ruta de la "Base de Datos"
const RUTA_DB = "user://resultados_test.json"

func guardar_nuevo_resultado(respuestas_nuevas: Array):
	# 1. Cargar la DB existente (Deserialización)
	var db_completa = _cargar_base_datos()
	
	# 2. Crear el nuevo registro (Struct/Object)
	var nuevo_registro = {
		"fecha": Time.get_datetime_string_from_system(),
		"respuestas": respuestas_nuevas
		# Podrías añadir "puntuacion" o lo que quieras aquí
	}
	
	# 3. Modificar en Memoria (std::vector::push_back)
	# Accedemos al array "registros" y añadimos el nuevo
	db_completa["registros"].append(nuevo_registro)
	
	# 4. Guardar todo de nuevo (Serialización y Volcado)
	_guardar_en_disco(db_completa)

# --- Métodos Privados Helper (para mantener el código limpio) ---

func _cargar_base_datos() -> Dictionary:
	# Si el archivo no existe, devolvemos una estructura vacía inicializada
	if not FileAccess.file_exists(RUTA_DB):
		return { "registros": [] } # Equivalente a inicializar el struct base
	
	# Leemos el archivo
	var archivo = FileAccess.open(RUTA_DB, FileAccess.READ)
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
	var archivo = FileAccess.open(RUTA_DB, FileAccess.WRITE)
	if archivo:
		# Convertimos el diccionario completo a texto
		var json_string = JSON.stringify(datos, "\t")
		archivo.store_string(json_string)
		archivo.close()
		print("Base de datos actualizada con nuevo registro en user://resultados_test.json.")

func _ready():
	# 1. Cargar la primera pregunta nada más empezar
	actualizar_interfaz()
	
	# 2. Conectar las señales de los botones
	# Esto hace que cuando se pulse, se ejecute la función indicada
	boton_si.pressed.connect(_cuando_pulsa_si)
	boton_no.pressed.connect(_cuando_pulsa_no)

# Esta función se encarga de cambiar el texto
func actualizar_interfaz():
	# Verificamos si todavía quedan preguntas
	if indice_pregunta_actual < lista_preguntas.size():
		label_pregunta.text = lista_preguntas[indice_pregunta_actual]
	else:
		fin_del_juego()

# Lógica cuando pulsa SI
func _cuando_pulsa_si():
	guardar_y_avanzar("PREGUNTA " + str(indice_pregunta_actual) + ": SI")

# Lógica cuando pulsa NO
func _cuando_pulsa_no():
	guardar_y_avanzar("PREGUNTA " + str(indice_pregunta_actual) + ": NO")

# Función central que hace el trabajo sucio
func guardar_y_avanzar(respuesta_elegida):
	# 1. Guardamos la respuesta en nuestra lista
	respuestas_guardadas.append(respuesta_elegida)
	print("Respuesta guardada: ", respuesta_elegida)
	
	# 2. Avanzamos al siguiente número de pregunta
	indice_pregunta_actual += 1
	
	# 3. Actualizamos el texto en pantalla
	actualizar_interfaz()

func fin_del_juego():
	label_pregunta.text = "Enquesta acabada!"
	# Ocultamos los botones para que no puedan seguir pulsando
	boton_si.visible = false
	boton_no.visible = false
	
	guardar_nuevo_resultado(respuestas_guardadas)
	
	# Aquí podrías cambiar de escena o mostrar resultados
