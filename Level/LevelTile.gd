class_name LevelTile
extends Node2D


signal input_event(tile, event)


enum { # Direction
	NORTH,
	EAST,
	SOUTH,
	WEST
}


enum { # Event
	SELECTED,
	DESELECTED,
	ACCEPTED
}


onready var damage_label = $Labels/DamageLabel


var level
var step = Vector2(31, 22)
var neighbors = {}


func setup_neighbors():
	for other_tile in level.tiles:
		if global_position + Vector2(-step.x, -step.y) == other_tile.global_position:
			neighbors[NORTH] = other_tile
			other_tile.neighbors[SOUTH] = self
		elif global_position + Vector2(step.x, -step.y) == other_tile.global_position:
			neighbors[EAST] = other_tile
			other_tile.neighbors[WEST] = self
		elif global_position + Vector2(step.x, step.y) == other_tile.global_position:
			neighbors[SOUTH] = other_tile
			other_tile.neighbors[NORTH] = self
		elif global_position + Vector2(-step.x, step.y) == other_tile.global_position:
			neighbors[WEST] = other_tile
			other_tile.neighbors[EAST] = self


func mark(color: Color):
	$Mark.modulate = color
	$Mark.visible = true


func unmark():
	$Mark.visible = false


func is_marked() -> bool:
	return $Mark.visible


func update_border_visibility():
	$Mark/BorderNorth.visible = neighbors.has(NORTH) and not neighbors[NORTH].is_marked()
	$Mark/BorderEast.visible = neighbors.has(EAST) and not neighbors[EAST].is_marked()
	$Mark/BorderSouth.visible = neighbors.has(SOUTH) and not neighbors[SOUTH].is_marked()
	$Mark/BorderWest.visible = neighbors.has(WEST) and not neighbors[WEST].is_marked()


func show_path(previous_tile: LevelTile, next_tile: LevelTile, color: Color):
	var path = [previous_tile, next_tile]
	$Path.modulate = color
	if path.has(null):
		$Path/ToNorth.visible = neighbors.has(NORTH) and path.has(neighbors[NORTH])
		$Path/ToEast.visible = neighbors.has(EAST) and path.has(neighbors[EAST])
		$Path/ToSouth.visible = neighbors.has(SOUTH) and path.has(neighbors[SOUTH])
		$Path/ToWest.visible = neighbors.has(WEST) and path.has(neighbors[WEST])
	else:
		$Path/NorthToEast.visible = path.has(neighbors.get(NORTH)) and path.has(neighbors.get(EAST))
		$Path/EastToSouth.visible = path.has(neighbors.get(EAST)) and path.has(neighbors.get(SOUTH))
		$Path/SouthToWest.visible = path.has(neighbors.get(SOUTH)) and path.has(neighbors.get(WEST))
		$Path/WestToNorth.visible = path.has(neighbors.get(WEST)) and path.has(neighbors.get(NORTH))
		$Path/NorthToSouth.visible = path.has(neighbors.get(NORTH)) and path.has(neighbors.get(SOUTH))
		$Path/EastToWest.visible = path.has(neighbors.get(EAST)) and path.has(neighbors.get(WEST))


func hide_path():
	for path in $Path.get_children():
		path.visible = false


func _on_input_event(_viewport, event, _shape_idx):
	emit_signal("input_event", self, ACCEPTED if event.is_action_pressed("tile_accept") else SELECTED)


func _on_mouse_exited():
	emit_signal("input_event", self, DESELECTED)
