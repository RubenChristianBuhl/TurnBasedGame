class_name LevelInterface
extends Control


var _skill_button_scene = load("res://Level/Interface/SkillButton.tscn")
var _current_character: Character
var _current_tile: LevelTile
var _active_tweens_count = 0


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
	if not is_tween_running():
		_current_character.select_skill(skill)


func _process(_delta):
	if Input.is_action_just_pressed("skill_cancel"):
		if _current_character is PlayerCharacter and not is_tween_running():
			_current_character.select_skill(null)


func _on_tile_input_event(tile: LevelTile, event: int):
	if _current_character is PlayerCharacter and not is_tween_running():
		if event == LevelTile.DESELECTED:
			if _current_tile == tile:
				_current_tile = null
				_current_character.select_target(null, false)
		elif event == LevelTile.ACCEPTED or _current_tile != tile:
			_current_tile = tile
			_current_character.select_target(tile, event == LevelTile.ACCEPTED)
	else:
		_current_tile = null


func _on_tween_started(_object: Object, _key: NodePath):
	_active_tweens_count += 1


func _on_tween_completed(_object: Object, _key: NodePath):
	_active_tweens_count -= 1


func is_tween_running() -> bool:
	return _active_tweens_count != 0
