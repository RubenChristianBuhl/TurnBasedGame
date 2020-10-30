class_name DamageEffect
extends Effect


var _damage_amount: int
var _targeted_tile: LevelTile
var _targeted_character


func _init(level, target: LevelTile, amount: int).(level, target):
	_damage_amount = amount
	_targeted_tile = target
	_targeted_character = level.get_character_at_tile(target)


func preview():
	_targeted_tile.damage_label.text = str(_damage_amount)


func reset():
	_targeted_tile.damage_label.text = ""


func cause():
	if _targeted_character != null:
		_targeted_character.health -= _damage_amount
