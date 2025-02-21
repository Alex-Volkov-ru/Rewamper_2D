extends Node
class_name SaveManager

var save_file_path := "user://save_data.json"
var kill_mobs_count = 0
var save_data := {
	"coins": 0,
	"talents": {},
	'max_kill_mobs_count': 0,
}


# === ПРОВЕРКА И ОБНОВЛЕНИЕ РЕКОРДА ===
func check_new_record():
	print("kill_mobs_count:", kill_mobs_count)
	print("max_kill_mobs_count:", save_data["max_kill_mobs_count"])
	
	if kill_mobs_count > save_data["max_kill_mobs_count"]:
		save_data["max_kill_mobs_count"] = kill_mobs_count  # Обновляем максимальный рекорд
		print("Новый рекорд! Значение kill_mobs_count:", kill_mobs_count)
		print("Старый рекорд:", save_data["max_kill_mobs_count"])
		
		send_to_leaderboard(save_data["max_kill_mobs_count"])
		print("Рекорд отправлен в лидерборд: ", save_data["max_kill_mobs_count"])

	kill_mobs_count = 0  # Обнуляем текущие убийства
	save()  # Сохраняем данные
	

# === ОТПРАВКА В ЛИДЕРБОРД ===
func send_to_leaderboard(record: int):
	if Bridge.leaderboard.is_supported:
		var options = {
			"leaderboardName": "leader",  # Твой лидерборд
			"score": record  # Лучший рекорд
		}
		Bridge.leaderboard.set_score(options, Callable(self, "_on_set_score_completed"))
	else:
		print("Лидерборды не поддерживаются на этой платформе.")

# === CALLBACK ОТВЕТА ОТ ЛИДЕРБОРДА ===
func _on_set_score_completed(success):
	if success:
		print("Рекорд успешно отправлен в лидерборд!")
	else:
		print("Ошибка при отправке рекорда в лидерборд.")

# === СОХРАНЕНИЕ ДАННЫХ ===
func save():
	if _is_web():
		_save_to_local_storage()
	else:
		_save_to_file()

# === ПРОВЕРКА ПЛАТФОРМЫ (БРАУЗЕР ИЛИ НЕТ) ===
func _is_web() -> bool:
	return OS.get_name() == "Web"

# === СОХРАНЕНИЕ В localStorage (ДЛЯ БРАУЗЕРА) ===
func _save_to_local_storage():
	var json_data = JSON.stringify(save_data)
	JavaScriptBridge.eval("localStorage.setItem('save_data', '" + json_data + "');")

# === СОХРАНЕНИЕ В ФАЙЛ (ДЛЯ ПК И МОБИЛЬНЫХ) ===
func _save_to_file():
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data, "\t")
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

# === ЗАГРУЗКА ИЗ localStorage (ДЛЯ БРАУЗЕРА) ===
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
	save()

# === ЗАГРУЗКА ТАЛАНТОВ ===
func load_talents() -> Dictionary:
	return save_data.get("talents", {})

# === СОХРАНЕНИЕ ПРИ ВЫХОДЕ ===
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Игра закрывается, сохраняем данные...")
		save()
