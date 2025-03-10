extends PanelContainer
class_name AbilityUpgradeCard

signal card_selected


@onready var name_label = %NameLabel
@onready var description_label = %DescriptionLabel
@onready var icon_texture_rect: TextureRect = %IconTextureRect


func set_ability_upgrade (upgrade: AbilityUpgrade):
	name_label.text = upgrade.name
	description_label.text = upgrade.description
	icon_texture_rect.texture = upgrade.icon
	


func _on_gui_input(event):
	if event.is_action_pressed("left_click"):
		card_selected.emit()
