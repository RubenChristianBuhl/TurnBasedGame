class_name Skill
extends Node


var image: Texture
var tile_color = Color(1.0, 0.0, 0.0)
var _effects = []
var _tile_distance: TileDistance


func get_valid_tiles(_level, _user) -> Array:
	return []


func set_tile_effects(_level, _tile: LevelTile, _user):
	pass


func get_effective_tiles(level, targets: Array, user) -> Array:
	var effective_tiles = []
	var valid_tiles = get_valid_tiles(level, user)
	for target in targets:
		if valid_tiles.has(target.tile):
			effective_tiles.append(target.tile)
	return effective_tiles


func preview():
	if _tile_distance != null:
		_tile_distance.preview()
	for effect in _effects:
		effect.preview()
		for target in effect.level.get_targets_at_tile(effect.tile):
			target.preview(effect)


func reset():
	if _tile_distance != null:
		_tile_distance.reset()
	for effect in _effects:
		effect.reset()
		for target in effect.level.get_targets_at_tile(effect.tile):
			target.reset(effect)


func cause(animated: bool = true):
	reset()
	if animated:
		var animation = _animate()
		if animation is GDScriptFunctionState and animation.is_valid():
			yield(animation, "completed")
	var effect_causes = []
	for effect in _effects:
		effect_causes.append(_cause_effect(effect, animated))
	for effect_cause in effect_causes:
		if effect_cause is GDScriptFunctionState and effect_cause.is_valid():
			yield(effect_cause, "completed")
	_effects.clear()


func _cause_effect(effect: Effect, animated: bool):
	if animated:
		var animation = effect.animate()
		if animation is GDScriptFunctionState and animation.is_valid():
			yield(animation, "completed")
	effect.cause()
	for target in effect.level.get_targets_at_tile(effect.tile):
		target.cause(effect)


func _animate():
	pass
