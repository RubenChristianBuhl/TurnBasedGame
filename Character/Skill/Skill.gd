class_name Skill
extends Node


signal caused(skill)


var image: Texture
var target_color = Color(1.0, 0.0, 0.0)
var _effects = []
var _target_distance: TargetDistance


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
	if _target_distance != null:
		_target_distance.preview()
	for effect in _effects:
		effect.preview()


func reset():
	if _target_distance != null:
		_target_distance.reset()
	for effect in _effects:
		effect.reset()


func cause(animated: bool = true):
	reset()
	if animated:
		_animate()
	else:
		for effect in _effects:
			effect.cause()
		emit_signal("caused", self)


func _animate():
	cause(false)
