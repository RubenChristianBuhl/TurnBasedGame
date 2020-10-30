class_name MoveEffect
extends Effect


var _modulated_alpha = 0.5
var _moving_character
var _original_character
var _original_tile: LevelTile


func _init(level, target: LevelTile, character).(level, target):
	_moving_character = character


func preview():
	_original_character = _moving_character.duplicate()
	_original_tile = _moving_character.tile
	_moving_character.tile = _target
	_original_character.modulate.a = _modulated_alpha
	_level.preview.add_child(_original_character)
	_original_character.health_bar.visible = false


func reset():
	if _original_character != null:
		_original_character.queue_free()
		_moving_character.tile = _original_tile


func cause():
	_moving_character.tile = _target
