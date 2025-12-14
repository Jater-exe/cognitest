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

	# 2. ANALIZAR DATOS
	var analisis_vp = _analizar_vp(datos_vp.get("registros", []))
	var analisis_survey = _analizar_survey(datos_survey.get("registros", []))
	
	var vp_recientes = _obtener_ultimos(datos_vp_completos, CANTIDAD_VP)
	var survey_recientes = _obtener_ultimos(datos_survey_completos, CANTIDAD_SURVEY)
	
	# 3. COMBINAR DATOS
	var informe_final = {
		"fecha_generacion": Time.get_datetime_string_from_system(),
		"resumen_ejecutivo": {
			"total_tests_vp": datos_vp.get("registros", []).size(),
			"total_encuestas": datos_survey.get("registros", []).size()
		},
		"analisis_velocidad_procesamiento": analisis_vp,
		"analisis_cognitivo_encuesta": analisis_survey,
		# Aquí incluimos los datos crudos originales por si se necesitan
		"datos_crudos_vp": datos_vp.get("registros", []),
		"datos_crudos_encuesta": datos_survey.get("registros", [])
	}
	
	# 4. GUARDAR RESULTADO
	_guardar_json(PATH_INFORME, informe_final)
	print("--- INFORME GENERADO EN: " + PATH_INFORME + " ---")


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
func _analizar_vp(lista_registros: Array) -> Dictionary:
	if lista_registros.is_empty():
		return {"mensaje": "Sin datos"}
		
	var suma_tiempo = 0.0
	var conteo_lentos = 0 # Cantidad de veces que superó los 9 segundos (true)
	
	for reg in lista_registros:
		# En tu script anterior guardamos "raw_wait_time" (float) y "time_delay" (bool)
		# Usamos get() por seguridad en caso de que alguna clave falte
		var tiempo = reg.get("raw_wait_time", 0.0)
		var es_lento = reg.get("time_delay", false)
		
		suma_tiempo += tiempo
		if es_lento:
			conteo_lentos += 1
			
	var promedio = suma_tiempo / lista_registros.size()
	
	return {
		"tiempo_promedio_reaccion": snapped(promedio, 0.01), # Redondeado a 2 decimales
		"intentos_fallidos_o_lentos": conteo_lentos,
		"tasa_exito": str(snapped((1.0 - (float(conteo_lentos) / lista_registros.size())) * 100, 0.1)) + "%"
	}

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
