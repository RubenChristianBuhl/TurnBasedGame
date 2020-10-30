class_name MoveSkill
extends Skill


func _init():
	target_color = Color(0.0, 1.0, 0.0)


func get_valid_targets(level, user) -> Array:
	var enemy_tiles = []
	var character_tiles = []
	for character in level.characters:
		character_tiles.append(character.tile)
		if level.player_characters.has(character) != level.player_characters.has(user):
			enemy_tiles.append(character.tile)
	return level.get_tiles_in_range(user.tile, user.stats.move_range, enemy_tiles, character_tiles)


func set_target_effects(level, target_tile: LevelTile, user):
	_effects = [MoveEffect.new(level, target_tile, user)]


func get_effective_targets(level, target_characters: Array, user) -> Array:
	var targets = []
	for target_character in target_characters:
		for skill in user.skills:
			targets = skill.get_valid_targets(level, target_character)
	var min_distance_valid_targets = []
	var min_distance: int
	for valid_target in get_valid_targets(level, user) + [user.tile]:
		for target in targets:
			var distance = level.get_tile_path(valid_target, target).size()
			if distance > 0:
				if min_distance_valid_targets.empty() or distance < min_distance:
					min_distance = distance
					min_distance_valid_targets = [valid_target]
				elif distance == min_distance and not min_distance_valid_targets.has(valid_target):
					min_distance_valid_targets.append(valid_target)
	return min_distance_valid_targets
