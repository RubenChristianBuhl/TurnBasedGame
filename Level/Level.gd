class_name Level
extends Node


signal current_character_changed(current_character)


onready var tiles = $Tiles.get_children()
onready var character_duplicates = $Characters/Duplicates


var characters: Array setget, _get_characters
var targets: Array setget, _get_targets
var player_characters: Array setget, _get_player_characters
var _current_character_index = -1
var _astar = AStar2D.new()
var _astar_ids = {}


func _get_tile(astar_id: int) -> LevelTile:
	for tile in _astar_ids:
		if _astar_ids[tile] == astar_id:
			return tile
	return null


func _setup_astar():
	var id = 0
	for tile in tiles:
		_astar_ids[tile] = id
		_astar.add_point(id, tile.position)
		id += 1
	for tile in _astar_ids:
		for neighbor in tile.neighbors.values():
			_astar.connect_points(_astar_ids[tile], _astar_ids[neighbor], false)


func _get_id_path(from_tile: LevelTile, to_tile: LevelTile, disabled_path_tiles: Array = []) -> Array:
	for disabled_path_tile in disabled_path_tiles:
		_astar.set_point_disabled(_astar_ids[disabled_path_tile])
	var id_path = _astar.get_id_path(_astar_ids[from_tile], _astar_ids[to_tile])
	for disabled_path_tile in disabled_path_tiles:
		_astar.set_point_disabled(_astar_ids[disabled_path_tile], false)
	return id_path


func get_tile_path(from_tile: LevelTile, to_tile: LevelTile, disabled_path_tiles: Array = []) -> Array:
	var path = []
	for id in _get_id_path(from_tile, to_tile, disabled_path_tiles):
		path.append(_get_tile(id))
	return path


func get_tiles_in_range(from_tile: LevelTile, tile_range: int,
		disabled_path_tiles: Array = [], disabled_end_tiles: Array = []) -> Array:
	var tiles_in_range = []
	for tile in tiles:
		if not disabled_end_tiles.has(tile):
			var id_path = _get_id_path(from_tile, tile, disabled_path_tiles)
			if not id_path.empty() and id_path.size() - 1 <= tile_range and tile != from_tile:
				tiles_in_range.append(tile)
	return tiles_in_range


func get_tiles_in_direction(from_tile: LevelTile, direction: int) -> Array:
	if from_tile.neighbors.has(direction):
		var tile_in_direction = from_tile.neighbors[direction]
		return [tile_in_direction] + get_tiles_in_direction(tile_in_direction, direction)
	else:
		return []


func _get_characters() -> Array:
	return $Characters/Originals.get_children()


func _get_targets() -> Array:
	return self.characters + $Items.get_children()


func _get_player_characters() -> Array:
	var player = []
	for character in self.characters:
		if character is PlayerCharacter:
			player.append(character)
	return player


func _setup_characters():
	for character in self.characters:
		character.level = self
		character.connect("collapsed", self, "_on_character_collapsed")
		character.connect("turn_ended", self, "_on_turn_ended")


func get_targets_at_tile(tile: LevelTile) -> Array:
	var targets_at_tile = []
	for target in self.targets:
		if target.preview_tile == tile:
			targets_at_tile.append(target)
	return targets_at_tile


func _on_character_collapsed(character: Character):
	$Characters/Originals.remove_child(character)
	character.queue_free()


func _on_turn_ended():
	if _are_all_enemies_dead():
		print("Player won!")
	elif _are_all_players_dead():
		print("Player lost!")
	else:
		_start_next_turn()


func _are_all_players_dead() -> bool:
	return self.player_characters.empty()


func _are_all_enemies_dead() -> bool:
	return self.characters.size() == self.player_characters.size()


func mark_tiles(mark: Array, color: Color):
	for tile in mark:
		tile.mark(color, true)
	for tile in mark:
		tile.update_group_border()


func unmark_tiles():
	for tile in tiles:
		tile.unmark(true)


func _setup_tiles():
	for tile in tiles:
		tile.level = self
		tile.setup_neighbors()
		tile.connect("input_event", $Interface, "_on_tile_input_event")
		for target in self.targets:
			if tile.position == target.position:
				target.tile = tile


func _ready():
	_setup_tiles()
	_setup_characters()
	_setup_astar()
	_start_next_turn()


func _start_next_turn():
	_current_character_index = (_current_character_index + 1) % self.characters.size()
	emit_signal("current_character_changed", self.characters[_current_character_index])
	self.characters[_current_character_index].start_turn()
