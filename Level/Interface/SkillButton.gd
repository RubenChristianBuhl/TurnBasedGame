class_name SkillButton
extends ColorRect


signal skill_selected(skill)


var skill: Skill setget _set_skill, _get_skill


func _set_skill(new_skill: Skill):
	skill = new_skill
	$ColorRect/TextureButton.texture_normal = skill.image


func _get_skill() -> Skill:
	return skill


func _on_pressed():
	emit_signal("skill_selected", skill)
