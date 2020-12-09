class_name MoveSkill
extends Skill


var _animation_duration = 1.0
var _level
var _user
var _path: Array


func _init():
	tile_color = Color(0.0, 1.0, 0.0)


func _get_not_passable_tiles(level, target) -> Array:
	var not_passable_tiles = []
	for other_target in level.targets:
		if not other_target.is_passable(target):
			not_passable_tiles.append(other_target.tile)
	return not_passable_tiles


func _get_obstacle_tiles(level, target) -> Array:
	var obstacle_tiles = []
	for other_target in level.targets:
		if other_target.is_obstacle(target):
			obstacle_tiles.append(other_target.tile)
	return obstacle_tiles


func _get_tile_path(level, user, from_tile, to_tile: LevelTile) -> Array:
	var not_passable_tiles = _get_not_passable_tiles(level, user)
	return level.get_tile_path(from_tile, to_tile, not_passable_tiles)


func _get_tiles_in_range(level, from_user, tile_range: int) -> Array:
	var not_passable_tiles = _get_not_passable_tiles(level, from_user)
	var obstacle_tiles = _get_obstacle_tiles(level, from_user)
	return level.get_tiles_in_range(from_user.tile, tile_range, not_passable_tiles, obstacle_tiles)


func get_valid_tiles(level, user) -> Array:
	return _get_tiles_in_range(level, user, user.stats.move_range)


func set_tile_effects(level, tile: LevelTile, user):
	_effects = [MoveEffect.new(level, tile, user)]
	_path = _get_tile_path(level, user, user.tile, tile)
	_tile_distance = PathTileDistance.new(_path, tile_color)
	_level = level
	_user = user


func get_effective_tiles(level, targets: Array, user) -> Array:
	var tiles = []
	for target in targets:
		for skill in user.skills:
			tiles += skill.get_valid_tiles(level, target)
	var min_distance_valid_tiles = []
	var min_distance: int
	for valid_tile in get_valid_tiles(level, user) + [user.tile]:
		for tile in tiles:
			var distance = _get_tile_path(level, user, valid_tile, tile).size()
			if distance > 0:
				if min_distance_valid_tiles.empty() or distance < min_distance:
					min_distance = distance
					min_distance_valid_tiles = [valid_tile]
				elif distance == min_distance and not min_distance_valid_tiles.has(valid_tile):
					min_distance_valid_tiles.append(valid_tile)
	return min_distance_valid_tiles


func _animate():
	_user.tween.interpolate_method(self, "_animate_path", 0, _path.size(), _animation_duration)
	_user.tween.start()
	yield(_user.tween, "tween_all_completed")


func _animate_path(value: int):
	_level.unmark_tiles()
	if value < _path.size():
		var mark = get_valid_tiles(_level, _user) + [_user.tile]
		mark.erase(_path[value])
		_level.mark_tiles(mark, tile_color)
		_user.position = _path[value].position
