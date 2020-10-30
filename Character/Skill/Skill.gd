class_name Skill
extends Node


signal caused(skill)


var image: Texture
var target_color = Color(1.0, 0.0, 0.0)
var _effects = []


func get_valid_targets(_level, _user) -> Array:
	return []


func set_target_effects(_level, _target_tile: LevelTile, _user):
	pass


func get_effective_targets(level, target_characters: Array, user) -> Array:
	var effective_targets = []
	var valid_targets = get_valid_targets(level, user)
	for target_character in target_characters:
		if valid_targets.has(target_character.tile):
			effective_targets.append(target_character.tile)
	return effective_targets


func preview():
	for effect in _effects:
		effect.preview()


func reset():
	for effect in _effects:
		effect.reset()


func cause():
	for effect in _effects:
		effect.reset()
		effect.cause()
	emit_signal("caused", self)
