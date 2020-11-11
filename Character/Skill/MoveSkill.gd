class_name MoveSkill
extends Skill


var _animation_duration = 1.0
var _level
var _user
var _path: Array


func _init():
	target_color = Color(0.0, 1.0, 0.0)


func _get_enemy_tiles(level, user) -> Array:
	var enemy_tiles = []
	for enemy in level.get_enemy_characters(user):
		enemy_tiles.append(enemy.tile)
	return enemy_tiles


func get_valid_targets(level, user) -> Array:
	var enemy_tiles = _get_enemy_tiles(level, user)
	var character_tiles = []
	for character in level.characters:
		character_tiles.append(character.tile)
	return level.get_tiles_in_range(user.tile, user.stats.move_range, enemy_tiles, character_tiles)


func set_target_effects(level, target_tile: LevelTile, user):
	_effects = [MoveEffect.new(level, target_tile, user)]
	_path = level.get_tile_path(user.tile, target_tile, _get_enemy_tiles(level, user))
	_target_distance = PathTargetDistance.new(_path, target_color)
	_level = level
	_user = user


func get_effective_targets(level, target_characters: Array, user) -> Array:
	var targets = []
	for target_character in target_characters:
		for skill in user.skills:
			targets = skill.get_valid_targets(level, target_character)
	var min_distance_valid_targets = []
	var min_distance: int
	for valid_target in get_valid_targets(level, user) + [user.tile]:
		for target in targets:
			var distance = level.get_tile_path(valid_target, target, _get_enemy_tiles(level, user)).size()
			if distance > 0:
				if min_distance_valid_targets.empty() or distance < min_distance:
					min_distance = distance
					min_distance_valid_targets = [valid_target]
				elif distance == min_distance and not min_distance_valid_targets.has(valid_target):
					min_distance_valid_targets.append(valid_target)
	return min_distance_valid_targets


func _animate():
	_user.tween.interpolate_method(self, "_animate_path", 0, _path.size(), _animation_duration)
	_user.tween.interpolate_callback(self, _animation_duration, "cause", false)
	_user.tween.start()


func _animate_path(value: int):
	_level.unmark_tiles()
	if value < _path.size():
		var mark = get_valid_targets(_level, _user) + [_user.tile]
		mark.erase(_path[value])
		_level.mark_tiles(mark, target_color)
		_user.position = _path[value].position
