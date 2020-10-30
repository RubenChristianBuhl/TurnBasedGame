class_name LevelTile
extends Node2D


signal input_event(tile, event)


enum {
	SELECTED,
	DESELECTED,
	ACCEPTED
}


onready var damage_label = $Labels/DamageLabel


var level
var step = Vector2(31, 22)
var north_west: LevelTile
var north_east: LevelTile
var south_east: LevelTile
var south_west: LevelTile


func has_north_west() -> bool:
	return north_west != null


func has_north_east() -> bool:
	return north_east != null


func has_south_east() -> bool:
	return south_east != null


func has_south_west() -> bool:
	return south_west != null


func get_neighbors() -> Array:
	var neighbors = []
	for neighbor in [north_west, north_east, south_east, south_west]:
		if neighbor != null:
			neighbors.append(neighbor)
	return neighbors


func setup_neighbors():
	for other_tile in level.tiles:
		if global_position + Vector2(-step.x, -step.y) == other_tile.global_position:
			north_west = other_tile
			other_tile.south_east = self
		elif global_position + Vector2(step.x, -step.y) == other_tile.global_position:
			north_east = other_tile
			other_tile.south_west = self
		elif global_position + Vector2(step.x, step.y) == other_tile.global_position:
			south_east = other_tile
			other_tile.north_west = self
		elif global_position + Vector2(-step.x, step.y) == other_tile.global_position:
			south_west = other_tile
			other_tile.north_east = self


func mark(color: Color):
	$Mark.modulate = color
	$Mark.visible = true


func unmark():
	$Mark.visible = false


func is_marked() -> bool:
	return $Mark.visible


func update_border_visibility():
	$Mark/BorderNorthWest.visible = has_north_west() and not north_west.is_marked()
	$Mark/BorderNorthEast.visible = has_north_east() and not north_east.is_marked()
	$Mark/BorderSouthEast.visible = has_south_east() and not south_east.is_marked()
	$Mark/BorderSouthWest.visible = has_south_west() and not south_west.is_marked()


func _on_input_event(_viewport, event, _shape_idx):
	emit_signal("input_event", self, ACCEPTED if event.is_action_pressed("tile_accept") else SELECTED)


func _on_mouse_exited():
	emit_signal("input_event", self, DESELECTED)
