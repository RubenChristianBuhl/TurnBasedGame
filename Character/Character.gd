class_name Character
extends Target


signal turn_ended


export(Resource) var stats


var level
var skills: Array setget, _get_skills
var _move_skill = MoveSkill.new()


func _get_skills() -> Array:
	var character_skills = []
	for equipment in $Equipment.get_children():
		character_skills += equipment.skills
	return character_skills


func is_passable(target) -> bool:
	return not level.player_characters.has(target)


func is_obstacle(_target) -> bool:
	return true


func start_turn():
	_move()


func _move():
	var move_tiles = _move_skill.get_effective_tiles(level, level.player_characters, self)
	randomize()
	move_tiles.shuffle()
	var move_tile = tile if move_tiles.empty() else move_tiles.front()
	_move_skill.set_tile_effects(level, move_tile, self)
	var cause = _move_skill.cause()
	if cause is GDScriptFunctionState and cause.is_valid():
		yield(cause, "completed")
	_use_skill()


func _use_skill():
	var skill_tiles = []
	for skill in self.skills:
		for effective_tile in skill.get_effective_tiles(level, level.player_characters, self):
			skill_tiles.append([skill, effective_tile])
	randomize()
	skill_tiles.shuffle()
	if not skill_tiles.empty():
		var selected_skill = skill_tiles.front()[0]
		var selected_tile = skill_tiles.front()[1]
		selected_skill.set_tile_effects(level, selected_tile, self)
		var cause = selected_skill.cause()
		if cause is GDScriptFunctionState and cause.is_valid():
			yield(cause, "completed")
	emit_signal("turn_ended")


func _setup_health():
	self.health_bar = $HealthBar
	self.max_health = stats.max_health


func _ready():
	_setup_health()
