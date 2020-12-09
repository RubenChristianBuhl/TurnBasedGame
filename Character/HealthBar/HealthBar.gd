class_name HealthBar
extends Node2D


var max_value: int setget _set_max_value, _get_max_value
var current_value: int setget _set_current_value, _get_current_value


func _set_max_value(new_value: int):
	max_value = new_value


func _get_max_value() -> int:
	return max_value


func _set_current_value(new_value: int):
	current_value = new_value


func _get_current_value() -> int:
	return current_value


func show_preview(_value: int):
	pass


func hide_preview():
	pass
