extends Node
class_name SaveManager

var save_file_path := "user://save_data.json"
var save_data := {
	"coins": 0,
	"talents": {}
}

# === ПРОВЕРКА ПЛАТФОРМЫ (браузер или нет) ===
func _is_web() -> bool:
	return OS.get_name() == "Web"

# === СОХРАНЕНИЕ ДАННЫХ ===
func save():
	if _is_web():
		_save_to_local_storage()
	else:
		_save_to_file()

# === СОХРАНЕНИЕ В localStorage (для браузера) ===
func _save_to_local_storage():
	var json_data = JSON.stringify(save_data)
	JavaScriptBridge.eval("localStorage.setItem('save_data', '" + json_data + "');")
	print("Данные сохранены в localStorage.")

# === СОХРАНЕНИЕ В ЛОКАЛЬНЫЙ ФАЙЛ (для ПК и мобильных) ===
func _save_to_file():
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data, "\t")  # Форматирование для удобства
		file.store_string(json_string)
		file.close()
	else:
		print("Ошибка: Не удалось открыть файл для записи!")

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
			else:
				print("Ошибка: Не удалось разобрать JSON-файл!")

# === ЗАГРУЗКА ДАННЫХ ИЗ localStorage (для браузера) ===
func _load_from_local_storage():
	var json_data = JavaScriptBridge.eval("localStorage.getItem('save_data');")
	if json_data and json_data != "null":
		var json = JSON.new()
		var result = json.parse(json_data)
		if result == OK:
			save_data = json.data

# === СОХРАНЕНИЕ ТАЛАНТОВ ===
func save_talents(talents: Dictionary):
	save_data["talents"] = talents
	save()  # Сохраняем таланты

# === ЗАГРУЗКА ТАЛАНТОВ ===
func load_talents() -> Dictionary:
	return save_data.get("talents", {})

# === СОХРАНЕНИЕ ПРИ ВЫХОДЕ ИЗ ИГРЫ ===
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Игра закрывается, сохраняем данные...")
		save()
