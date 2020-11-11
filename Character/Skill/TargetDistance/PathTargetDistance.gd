class_name PathTargetDistance
extends TargetDistance


var _path: Array


func _init(path: Array, preview_color: Color = Color(1.0, 0.0, 0.0)):
	_preview_color = preview_color
	_path = path


func preview():
	for index in _path.size():
		var previous_tile = _path[index - 1] if index > 0 else null
		var next_tile = _path[index + 1] if index < _path.size() - 1 else null
		_path[index].show_path(previous_tile, next_tile, _preview_color)


func reset():
	for tile in _path:
		tile.hide_path()
