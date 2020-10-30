class_name Character
extends Node2D


signal died(character)
signal turn_ended


export var stats: Resource


onready var health_bar = $HealthBar
onready var health = stats.max_health setget _set_health, _get_health


var level
var tile: LevelTile setget _set_tile, _get_tile
var skills: Array setget, _get_skills
var _move_skill = MoveSkill.new()


func _set_health(new_health: int):
	health = new_health
	health_bar.current_value = health
	if health <= 0:
		emit_signal("died", self)


func _get_health() -> int:
	return health


func _set_tile(new_tile: LevelTile):
	tile = new_tile
	position = tile.position


func _get_tile() -> LevelTile:
	return tile


func _get_skills() -> Array:
	var character_skills = []
	for equipment in $Equipment.get_children():
		character_skills += equipment.skills
	return character_skills


func select_skill(_skill: Skill):
	pass


func select_target(_target: LevelTile, _is_accepted: bool):
	pass


func _on_skill_caused(skill: Skill):
	if skill == _move_skill:
		_use_skill()
	else:
		emit_signal("turn_ended")


func start_turn():
	_move()


func _move():
	var move_targets = _move_skill.get_effective_targets(level, level.player_characters, self)
	randomize()
	move_targets.shuffle()
	if not move_targets.empty() and move_targets.front() != tile:
		_move_skill.set_target_effects(level, move_targets.front(), self)
		_move_skill.cause()
	else:
		_use_skill()


func _use_skill():
	var skill_targets = []
	for skill in self.skills:
		for target in skill.get_effective_targets(level, level.player_characters, self):
			skill_targets.append([skill, target])
	randomize()
	skill_targets.shuffle()
	if not skill_targets.empty():
		var selected_skill = skill_targets.front()[0]
		var selected_target = skill_targets.front()[1]
		selected_skill.set_target_effects(level, selected_target, self)
		selected_skill.cause()
	else:
		emit_signal("turn_ended")


func _setup_health():
	health_bar.max_value = stats.max_health
	health_bar.current_value = health


func _connect_skill_signals():
	for skill in self.skills + [_move_skill]:
		skill.connect("caused", self, "_on_skill_caused")


func _ready():
	_setup_health()
	_connect_skill_signals()
