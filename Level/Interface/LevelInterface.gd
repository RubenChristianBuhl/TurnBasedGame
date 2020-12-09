class_name LevelInterface
extends Control


var _skill_button_scene = load("res://Level/Interface/SkillButton.tscn")
var _current_character: Character
var _current_tile: LevelTile
var _selection: GDScriptFunctionState


func _on_current_character_changed(character: Character):
	_current_character = character
	for skill_button in $SkillButtons.get_children():
		skill_button.queue_free()
	if _current_character is PlayerCharacter:
		for skill in character.skills:
			var skill_button = _skill_button_scene.instance()
			skill_button.skill = skill
			skill_button.connect("skill_selected", self, "_on_skill_selected")
			$SkillButtons.add_child(skill_button)


func _on_skill_selected(skill: Skill):
	if is_selection_completed():
		_selection = _current_character.select_skill(skill)


func _process(_delta):
	if Input.is_action_just_pressed("skill_cancel"):
		if _current_character is PlayerCharacter and is_selection_completed():
			_selection = _current_character.select_skill(null)


func _on_tile_input_event(tile: LevelTile, event: int):
	if _current_character is PlayerCharacter and is_selection_completed():
		if event == LevelTile.DESELECTED:
			if _current_tile == tile:
				_current_tile = null
				_selection = _current_character.select_tile(null, false)
		elif event == LevelTile.ACCEPTED or _current_tile != tile:
			_current_tile = tile
			_selection = _current_character.select_tile(tile, event == LevelTile.ACCEPTED)
	else:
		_current_tile = null


func is_selection_completed():
	return not (_selection is GDScriptFunctionState and _selection.is_valid())
