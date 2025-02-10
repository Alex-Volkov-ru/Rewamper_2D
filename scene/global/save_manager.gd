extends Node
class_name SaveManager

var save_file_path := "user://save_data.json"
var server_url := "https://yourserver.com/api/save_data"

var save_data := {
	"coins": 0,
	"talents": {}
}

var is_online := false  # Флаг: работаем локально или с сервером
var http_request: HTTPRequest

# === ПРОВЕРКА ПЛАТФОРМЫ ===
func _is_web() -> bool:
	return OS.get_name() == "Web"

# === СОХРАНЕНИЕ ДАННЫХ ===
func save():
	if _is_web():
		_save_to_local_storage()
	else:
		_save_to_file()

# === СОХРАНЕНИЕ НА ВЕБ (localStorage) ===
func _save_to_local_storage():
	var json_data = JSON.stringify(save_data)
	JavaScriptBridge.eval("localStorage.setItem('save_data', " + JSON.stringify(json_data) + ");")
	print("Данные сохранены в localStorage.")

# === СОХРАНЕНИЕ В ЛОКАЛЬНЫЙ ФАЙЛ ===
func _save_to_file():
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Данные сохранены локально.")

# === ЗАГРУЗКА ДАННЫХ ===
func _load_data():
	if _is_web():
		_load_from_local_storage()
	elif FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			var result = json.parse(content)
			if result == OK:
				save_data = json.data
				print("Данные загружены локально.")

# === ЗАГРУЗКА ДАННЫХ ИЗ localStorage (для Web) ===
func _load_from_local_storage():
	var json_data = JavaScriptBridge.eval("localStorage.getItem('save_data');")
	if json_data and json_data != "null":
		var json = JSON.new()
		var result = json.parse(json_data)
		if result == OK:
			save_data = json.data
			print("Данные загружены из localStorage.")

# === СОХРАНЕНИЕ ОТДЕЛЬНЫХ ДАННЫХ ===
func save_data_key(key: String, value):
	save_data[key] = value
	save()

# === СОХРАНЕНИЕ ТАЛАНТОВ ===
func save_talents(talents: Dictionary):
	save_data["talents"] = talents
	save()

# === ЗАГРУЗКА ОТДЕЛЬНЫХ ДАННЫХ ===
func load_data_key(key: String, default_value = null):
	return save_data.get(key, default_value)

func load_talents() -> Dictionary:
	return save_data.get("talents", {})
