class_name PlayerCharacter
extends Character


var _selected_skill: Skill
var _moved: bool


func select_skill(skill: Skill):
	if skill == null and not _moved:
		skill = _move_skill
	if _selected_skill != skill:
		if _selected_skill != null:
			level.unmark_tiles()
			_selected_skill.reset()
		_selected_skill = skill
		if skill != null:
			level.mark_tiles(skill.get_valid_targets(level, self), skill.target_color)


func select_target(target: LevelTile, is_accepted: bool):
	if _selected_skill != null:
		_selected_skill.reset()
		if target != null and _selected_skill.get_valid_targets(level, self).has(target):
			_selected_skill.set_target_effects(level, target, self)
			if is_accepted:
				level.unmark_tiles()
				_selected_skill.cause()
			else:
				_selected_skill.preview()


func _on_skill_caused(skill: Skill):
	if skill == _move_skill:
		_moved = true
		select_skill(null)
	else:
		emit_signal("turn_ended")


func start_turn():
	_moved = false
	select_skill(_move_skill)
