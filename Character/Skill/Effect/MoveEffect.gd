class_name MoveEffect
extends Effect


var character
var _modulate_alpha = 0.5
var _character_duplicate


func _init(level, tile: LevelTile, character).(level, tile):
	self.character = character
	self.character.preview_tile = tile


func preview():
	_character_duplicate = character.duplicate()
	character.position = tile.position
	_character_duplicate.modulate.a = _modulate_alpha
	level.character_duplicates.add_child(_character_duplicate)
	_character_duplicate.health_bar.visible = false


func reset():
	if _character_duplicate != null:
		_character_duplicate.queue_free()
		character.position = character.tile.position
		character.preview_tile = character.tile


func cause():
	character.tile = tile
