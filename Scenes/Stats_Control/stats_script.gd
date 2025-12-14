extends Control

const PATH_SUBJ = "res://JSON/resultados_test.json"
const PATH_VP = "res://JSON/test_VP.json"

# CONFIGURACIÓN: Cuántos guardar
const CANTIDAD_SURVEY = 7
const CANTIDAD_VP = 1

func _ready():
	# Al iniciar, ejecutamos el análisis. 
	# Puedes mover esto a una función conectada a un botón si prefieres.
	generar_informe_combinado()


func generar_informe_combinado():
	print("--- INICIANDO ANÁLISIS DE DATOS ---")
	
	# 1. RECOGER DATOS
	var datos_vp = _cargar_json(PATH_VP)
	var datos_survey = _cargar_json(PATH_SUBJ)
	
	if datos_vp.is_empty() and datos_survey.is_empty():
		print("Error: No se encontraron datos para analizar.")
		return
	
	var vp_recientes = _obtener_ultimos(datos_vp, CANTIDAD_VP)
	var survey_recientes = _obtener_ultimos(datos_survey, CANTIDAD_SURVEY)
	
	# 2. ANALIZAR DATOS
	var analisis = _analizar_datos(datos_vp.get("registros", []), datos_survey.get("registros", []))


# --- NUEVA FUNCIÓN DE FILTRADO ---
func _obtener_ultimos(lista: Array, cantidad: int) -> Array:
	# Si la lista tiene menos elementos de los que pedimos (ej. pedimos 7 y hay 3),
	# devolvemos toda la lista tal cual.
	if lista.size() <= cantidad:
		return lista
	
	# Si hay de sobra, hacemos un "slice" desde el final hacia atrás.
	# Formula: desde (Total - Cantidad) hasta el final.
	var inicio = lista.size() - cantidad
	return lista.slice(inicio)
	

# --- LÓGICA DE ANÁLISIS VP ---
func _analizar_datos(results_vp: Array, results_subj: Array):
	if results_vp.is_empty() or results_subj.is_empty():
		return {"mensaje": "Sin datos"}
	
	var sumas_categorias = {
		"ATENCIO": 0, "VEL_PROC": 0, "MEMORIA": 0, "FLU_VERB": 0, "FUNC_EXEC": 0
	}
	var problemes_categoria = {
		"ATENCIO": false, "VEL_PROC": false, "MEMORIA": false, "FLU_VERB": false, "FUNC_EXEC": false
	}
	var es_lento:
	
	for reg in results_vp:
		# En tu script anterior guardamos "raw_wait_time" (float) y "time_delay" (bool)
		# Usamos get() por seguridad en caso de que alguna clave falte
		es_lento = reg.get("time_delay")
	
	for reg in results_subj:
		# reg["puntuacio"] es un Array de Strings tipo ["ATENCIO: 1", "MEMORIA: 0", ...]
		var stats_array = reg.get("puntuacio", [])
		
		for item_string in stats_array:
			# Parseamos el string: "ATENCIO: 2" -> ["ATENCIO", " 2"]
			var partes = item_string.split(":")
			if partes.size() == 2:
				var categoria = partes[0].strip_edges()
				var valor = partes[1].strip_edges().to_int()
				
				if sumas_categorias.has(categoria) and problemes_categoria.has(categoria):
					sumas_categorias[categoria] += valor
					if(categoria == "ATENCIO" and valor <= 1):
						problemes_categoria[categoria] = true
					elif(categoria == "VEL_PROC" and (valor <= 1 or es_lento)):
						problemes_categoria[categoria] = true
					elif(categoria == "MEMORIA" and valor <= 1):
						problemes_categoria[categoria] = true
					elif(categoria == "FLU_VERB" and valor == 0):
						problemes_categoria[categoria] = true
					elif(categoria == "FUNC_EXEC" and valor <= 1):
						problemes_categoria[categoria] = true

# --- LÓGICA DE ANÁLISIS ENCUESTA ---
func _analizar_survey(lista_registros: Array) -> Dictionary:
	if lista_registros.is_empty():
		return {"mensaje": "Sin datos"}
	
	# Acumuladores para los promedios
	var sumas_categorias = {
		"ATENCIO": 0, "VEL_PROC": 0, "MEMORIA": 0, "FLU_VERB": 0, "FUNC_EXEC": 0
	}
	
	for reg in lista_registros:
		# reg["puntuacio"] es un Array de Strings tipo ["ATENCIO: 1", "MEMORIA: 0", ...]
		var stats_array = reg.get("puntuacio", [])
		
		for item_string in stats_array:
			# Parseamos el string: "ATENCIO: 2" -> ["ATENCIO", " 2"]
			var partes = item_string.split(":")
			if partes.size() == 2:
				var categoria = partes[0].strip_edges()
				var valor = partes[1].strip_edges().to_int()
				
				if sumas_categorias.has(categoria):
					sumas_categorias[categoria] += valor
	
	# Calcular promedios
	var promedios = {}
	var total_encuestas = lista_registros.size()
	
	for key in sumas_categorias:
		var media = float(sumas_categorias[key]) / total_encuestas
		promedios[key] = snapped(media, 0.1)
		
	return {
		"promedios_por_categoria": promedios,
		"total_puntos_acumulados": sumas_categorias
	}



# --- HERRAMIENTAS DE CARGA Y GUARDADO ---
func _cargar_json(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		print("Advertencia: No existe el archivo " + ruta)
		return {}
		
	var file = FileAccess.open(ruta, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK and json.data is Dictionary:
		return json.data
	else:
		return {}

func _guardar_json(ruta: String, datos: Dictionary):
	var file = FileAccess.open(ruta, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(datos, "\t")
		file.store_string(json_string)
		file.close()
