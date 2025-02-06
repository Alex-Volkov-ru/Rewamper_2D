#extends Node
#
## Проверяем, доступен ли JavaScriptBridge (работает только в браузере)
#func is_js_available() -> bool:
	#return JavaScriptBridge.has_instance()
#
## Функция сохранения данных в облако
#func save_game_data(data: Dictionary):
	#if is_js_available():
		#var json_string = JSON.stringify(data)  # Преобразуем словарь в JSON
		#var script = "ysdk.getStorage().setItem('game_data', '" + json_string + "');"
		#JavaScriptBridge.eval(script, false)
		#print("✅ Данные сохранены: ", json_string)
#
## Функция загрузки данных из облака
#func load_game_data() -> Dictionary:
	#if is_js_available():
		#var script = "ysdk.getStorage().getItem('game_data').then((data) => {return data;});"
		#var result = JavaScriptBridge.eval(script, true)
		#if result:
			#var json_data = JSON.parse_string(result)  # Преобразуем JSON в словарь
			#if json_data:
				#print("✅ Данные загружены: ", json_data)
				#return json_data
#
	## Если данных нет – возвращаем стандартные значения
	#print("⚠ Нет сохранённых данных, загружаем стандартные значения.")
	#return {"coins": 0, "level": 1, "experience": 0, "talents": []}
