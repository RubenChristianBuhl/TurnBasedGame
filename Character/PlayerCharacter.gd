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
			level.mark_tiles(skill.get_valid_tiles(level, self), skill.tile_color)


func select_tile(selected_tile: LevelTile, is_accepted: bool):
	if _selected_skill != null:
		_selected_skill.reset()
		if selected_tile != null and _selected_skill.get_valid_tiles(level, self).has(selected_tile):
			_selected_skill.set_tile_effects(level, selected_tile, self)
			if is_accepted:
				level.unmark_tiles()
				var cause = _selected_skill.cause(_selected_skill != _move_skill)
				if cause is GDScriptFunctionState and cause.is_valid():
					yield(cause, "completed")
				if _selected_skill == _move_skill:
					_moved = true
					select_skill(null)
				else:
					emit_signal("turn_ended")
			else:
				_selected_skill.preview()


func is_passable(character) -> bool:
	return level.player_characters.has(character)


func start_turn():
	_moved = false
	select_skill(_move_skill)
