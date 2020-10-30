class_name Level
extends Node


signal current_character_changed(current_character)


onready var tiles = $Tiles.get_children()
onready var preview = $YSort/Preview


var characters: Array setget, _get_characters
var player_characters: Array setget, _get_player_characters
var _next_character_index = 0
var _current_character: Character
var _current_tile: LevelTile
var _astar = AStar2D.new()
var _astar_ids = {}


func _get_tile(astar_id: int) -> LevelTile:
	for node in _astar_ids:
		if _astar_ids[node] == astar_id:
			return node
	return null


func _setup_astar():
	var id = 0
	for node in tiles:
		_astar_ids[node] = id
		_astar.add_point(id, node.position)
		id += 1
	for node in _astar_ids:
		for neighbor in node.get_neighbors():
			_astar.connect_points(_astar_ids[node], _astar_ids[neighbor], false)


func get_tile_path(from_tile: LevelTile, to_tile: LevelTile) -> Array:
	var path = []
	var id_path = _astar.get_id_path(_astar_ids[from_tile], _astar_ids[to_tile])
	for id in id_path:
		path.append(_get_tile(id))
	return path


func get_tiles_in_range(from_tile: LevelTile, tile_range: int,
		disabled_path_tiles: Array = [], disabled_target_tiles: Array = []) -> Array:
	var tiles_in_range = []
	for disabled_path_tile in disabled_path_tiles:
		_astar.set_point_disabled(_astar_ids[disabled_path_tile])
	for tile in tiles:
		if not disabled_target_tiles.has(tile):
			var id_path = _astar.get_id_path(_astar_ids[from_tile], _astar_ids[tile])
			if not id_path.empty() and id_path.size() - 1 <= tile_range and tile != from_tile:
				tiles_in_range.append(tile)
	for disabled_path_tile in disabled_path_tiles:
		_astar.set_point_disabled(_astar_ids[disabled_path_tile], false)
	return tiles_in_range


func _get_characters() -> Array:
	return $YSort/Characters.get_children()


func _get_player_characters() -> Array:
	var player = []
	for character in self.characters:
		if character is PlayerCharacter:
			player.append(character)
	return player


func _setup_characters():
	for character in self.characters:
		character.level = self
		character.connect("died", self, "_on_character_died")
		character.connect("turn_ended", self, "_on_turn_ended")
		for node in tiles:
			if node.position == character.position:
				character.tile = node


func get_character_at_tile(tile: LevelTile) -> Character:
	for character in self.characters:
		if character.tile == tile:
			return character
	return null


func _on_character_died(character: Character):
	$YSort/Characters.remove_child(character)
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


func _on_tile_input_event(tile: LevelTile, event: int):
	if event == LevelTile.DESELECTED:
		if _current_tile == tile:
			_current_tile = null
			_current_character.select_target(null, false)
	elif event == LevelTile.ACCEPTED or _current_tile != tile:
		_current_tile = tile
		_current_character.select_target(tile, event == LevelTile.ACCEPTED)


func mark_tiles(mark: Array, color: Color):
	for tile in mark:
		tile.mark(color)
	for tile in mark:
		tile.update_border_visibility()


func unmark_tiles():
	for tile in tiles:
		tile.unmark()


func _setup_tiles():
	for tile in tiles:
		tile.level = self
		tile.setup_neighbors()
		tile.connect("input_event", self, "_on_tile_input_event")


func _ready():
	_setup_tiles()
	_setup_characters()
	_setup_astar()
	_start_next_turn()


func _start_next_turn():
	_current_character = self.characters[_next_character_index]
	_next_character_index = (_next_character_index + 1) % self.characters.size()
	emit_signal("current_character_changed", _current_character)
	_current_character.start_turn()
