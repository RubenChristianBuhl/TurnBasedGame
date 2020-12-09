class_name PushEffect
extends Effect


var direction: int
var collision_damage: int
var _arrow_color = Color(1.0, 1.0, 0.0)
var _small_arrow_color = Color(1.0, 1.0, 1.0, 0.2)
var _pushes = []


func _init(level, tile: LevelTile, direction: int,
		distance: int = 1, collision_damage: int = 1).(level, tile):
	self.direction = direction
	self.collision_damage = collision_damage
	for target in level.get_targets_at_tile(tile):
		if target.is_pushable:
			var push = Push.new(target)
			for tile_in_direction in level.get_tiles_in_direction(tile, direction).slice(0, distance - 1):
				for other_target in level.targets:
					if other_target.is_obstacle(target) and other_target.preview_tile == tile_in_direction:
						push.collisions.append(other_target)
						other_target.preview_health -= collision_damage
				if push.collisions.empty():
					push.tiles.append(tile_in_direction)
					target.preview_tile = tile_in_direction
				else:
					push.collisions.append(target)
					target.preview_health -= collision_damage
					break
			_pushes.append(push)


func preview():
	var small = true
	for push in _pushes:
		small = small and push.tiles.empty() and push.collisions.empty()
		for target in push.collisions:
			target.show_preview_health()
		if not push.collisions.empty():
			push.collisions.front().tile.show_collision(_arrow_color)
	tile.show_arrow(direction, _small_arrow_color if small else _arrow_color, small)
	tile.mark(_small_arrow_color if _pushes.empty() else _arrow_color)


func reset():
	tile.hide_arrow()
	tile.unmark()
	for push in _pushes:
		for target in push.collisions:
			target.hide_preview_health()
		if not push.collisions.empty():
			push.collisions.front().tile.hide_collision()
		push.target.preview_tile = push.target.tile


func cause():
	for push in _pushes:
		if not push.tiles.empty():
			push.target.tile = push.tiles.back()
		if not push.collisions.empty():
			for target in push.collisions:
				target.health -= collision_damage


func animate():
	for push in _pushes:
		push.target.tween.interpolate_method(push, "animate", 0, push.animation_size, push.animation_duration)
		push.target.tween.start()
	for push in _pushes:
		if push.target.tween.is_active():
			yield(push.target.tween, "tween_all_completed")


class Push:
	var target
	var tiles = []
	var collisions = []
	var animation_duration_per_tile = 0.2
	var animation_duration: float setget, _get_animation_duration
	var animation_size: float setget, _get_animation_size


	func _init(target):
		self.target = target


	func _get_animation_duration() -> float:
		return self.animation_size * animation_duration_per_tile


	func _get_animation_size() -> float:
		return tiles.size() if collisions.empty() else tiles.size() + 1


	func animate(value: float):
		var tile_distance = Vector2.ZERO
		var collision_distance = Vector2.ZERO
		if not tiles.empty():
			tile_distance = tiles.back().position - target.tile.position
		if not collisions.empty():
			var collision_value = max(0, value - tiles.size())
			collision_value -= max(0, collision_value - 0.5) * 2
			collision_distance = collisions.front().position - target.tile.position - tile_distance
			collision_distance *= collision_value
		if not tiles.empty():
			tile_distance *= min(1, value / tiles.size())
		target.position = target.tile.position + tile_distance + collision_distance
