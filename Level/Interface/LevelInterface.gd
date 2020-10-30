class_name LevelInterface
extends Control


var _current_character: Character
var _skill_button_scene = load("res://Level/Interface/SkillButton.tscn")


func _on_current_character_changed(character: Character):
	_current_character = character
	for skill_button in $SkillButtons.get_children():
		skill_button.queue_free()
	for skill in character.skills:
		var skill_button = _skill_button_scene.instance()
		skill_button.skill = skill
		skill_button.connect("skill_selected", self, "_on_skill_selected")
		$SkillButtons.add_child(skill_button)


func _on_skill_selected(skill: Skill):
	_current_character.select_skill(skill)


func _process(_delta):
	if Input.is_action_just_pressed("skill_cancel"):
		_current_character.select_skill(null)
