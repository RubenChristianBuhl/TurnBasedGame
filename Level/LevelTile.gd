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


func mark(color: Color, group: bool = false):
	var mark = $Mark/Group if group else $Mark/Single
	mark.modulate = color
	mark.visible = true


func unmark(group: bool = false):
	var mark = $Mark/Group if group else $Mark/Single
	mark.visible = false


func is_marked() -> bool:
	return $Mark/Group.visible or $Mark/Single.visible


func update_group_border():
	$Mark/Group/BorderNorth.visible = neighbors.has(NORTH) and not neighbors[NORTH].is_marked()
	$Mark/Group/BorderEast.visible = neighbors.has(EAST) and not neighbors[EAST].is_marked()
	$Mark/Group/BorderSouth.visible = neighbors.has(SOUTH) and not neighbors[SOUTH].is_marked()
	$Mark/Group/BorderWest.visible = neighbors.has(WEST) and not neighbors[WEST].is_marked()


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


func show_arrow(direction: int, color: Color, small: bool = false):
	var arrows = {
		NORTH: $Arrow/NorthSmall if small else $Arrow/North,
		EAST: $Arrow/EastSmall if small else $Arrow/East,
		SOUTH: $Arrow/SouthSmall if small else $Arrow/South,
		WEST: $Arrow/WestSmall if small else $Arrow/West
	}
	$Arrow.modulate = color
	arrows[direction].visible = true


func hide_arrow():
	for arrow in $Arrow.get_children():
		arrow.visible = false


func show_collision(color: Color):
	$Collision.modulate = color
	$Collision.visible = true


func hide_collision():
	$Collision.visible = false


func _on_input_event(_viewport, event, _shape_idx):
	emit_signal("input_event", self, ACCEPTED if event.is_action_pressed("tile_accept") else SELECTED)


func _on_mouse_exited():
	emit_signal("input_event", self, DESELECTED)
