class_name SlaySkill
extends Skill


var _damage = 2


func _init():
	image = load("res://Sprites/Skill/SlaySkill.png")


func get_valid_tiles(_level, user) -> Array:
	return user.tile.neighbors.values()


func set_tile_effects(level, tile: LevelTile, _user):
	_effects = [DamageEffect.new(level, tile, _damage)]
