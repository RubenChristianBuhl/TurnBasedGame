class_name Target
extends Node2D


signal collapsed(target)


export(bool) var is_pushable = false


onready var tween = $Tween


var tile: LevelTile setget _set_tile, _get_tile
var max_health: int setget _set_max_health, _get_max_health
var health: int setget _set_health, _get_health
var health_bar: HealthBar
var preview_tile: LevelTile
var preview_health: int


func _set_tile(new_tile: LevelTile):
	tile = new_tile
	preview_tile = tile
	position = tile.position


func _get_tile() -> LevelTile:
	return tile


func _set_health(new_health: int):
	if health > 0 and new_health <= 0:
		emit_signal("collapsed", self)
	health = new_health
	preview_health = new_health
	if health_bar != null:
		health_bar.current_value = new_health


func _get_health() -> int:
	return health


func _set_max_health(new_health: int):
	max_health = new_health
	health_bar.max_value = new_health
	self.health = new_health


func _get_max_health() -> int:
	return max_health


func show_preview_health():
	if health_bar != null:
		health_bar.show_preview(preview_health)


func hide_preview_health():
	preview_health = health
	if health_bar != null:
		health_bar.hide_preview()


func is_passable(_target) -> bool:
	return true


func is_obstacle(_target) -> bool:
	return false


func preview(_effect: Effect):
	pass


func reset(_effect: Effect):
	pass


func cause(_effect: Effect):
	pass
