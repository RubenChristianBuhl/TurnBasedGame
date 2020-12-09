class_name BombSkill
extends Skill


var _damage = 1


func _init():
	image = load("res://Sprites/Skill/BombSkill.png")


func get_valid_tiles(level, user) -> Array:
	var valid_tiles = []
	for direction in user.tile.neighbors:
		var tiles_in_direction = level.get_tiles_in_direction(user.tile, direction)
		tiles_in_direction.pop_front()
		valid_tiles += tiles_in_direction
	return valid_tiles


func set_tile_effects(level, tile: LevelTile, _user):
	_effects = [DamageEffect.new(level, tile, _damage)]
	for direction in tile.neighbors:
		_effects.append(PushEffect.new(level, tile.neighbors[direction], direction))
