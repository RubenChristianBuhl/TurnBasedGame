class_name SlaySkill
extends Skill


var _damage = 2


func _init():
	image = load("res://Sprites/Skill/SlaySkill.png")


func get_valid_targets(level, user) -> Array:
	return level.get_tiles_in_range(user.tile, 1)


func set_target_effects(level, target_tile: LevelTile, _user):
	_effects = [DamageEffect.new(level, target_tile, _damage)]
