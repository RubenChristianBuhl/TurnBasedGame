class_name CharacterHealthBar
extends HealthBar


export(int) var outline_width = 1
export(int) var max_width = 33
export(int) var max_element_width = 11
export(int) var element_height = 7
export(float) var preview_alpha setget _set_preview_alpha, _get_preview_alpha
export(Color, RGBA) var fill_color = Color(0.0, 1.0, 0.0, 1.0)
export(Color, RGBA) var outline_color = Color(0.0, 0.0, 0.0, 1.0)


var _preview_value: int
var _outline: Polygon2D
var _elements: Array


func _set_preview_alpha(new_alpha: float):
	preview_alpha = new_alpha
	_update_elements_alpha()


func _get_preview_alpha() -> float:
	return preview_alpha


func _set_max_value(new_value: int):
	max_value = new_value
	_update_polygons()


func _get_max_value() -> int:
	return max_value


func _set_current_value(new_value: int):
	current_value = int(clamp(new_value, 0, max_value))
	_preview_value = current_value
	_update_elements_alpha()


func _get_current_value() -> int:
	return current_value


func show_preview(value: int):
	_preview_value = value
	$AnimationPlayer.play("PreviewValue")


func hide_preview():
	$AnimationPlayer.stop()
	_preview_value = current_value
	_update_elements_alpha()


func _update_polygons():
	for polygon in $Polygons.get_children():
		polygon.queue_free()
	_elements = []
	if max_value > 0:
		var outlines_width = (max_value + 1) * outline_width
		var elements_width = max_width - outlines_width
		var element_width = int(min(round(elements_width / max_value), max_element_width))
		var width = element_width * max_value + outlines_width
		var height = element_height + 2 * outline_width
		var half_width = width / 2.0
		var half_height = height / 2.0
		_outline = _create_polygon(outline_color, [
			Vector2(-half_width, -half_height),
			Vector2(half_width, -half_height),
			Vector2(half_width, half_height),
			Vector2(-half_width, half_height)
		])
		var element_position = Vector2(-half_width + outline_width, -half_height + outline_width)
		var element_step = Vector2(element_width + outline_width, 0)
		for value in max_value:
			_elements.append(_create_polygon(fill_color, [
				Vector2(element_position.x, element_position.y),
				Vector2(element_position.x + element_width, element_position.y),
				Vector2(element_position.x + element_width, element_position.y + element_height),
				Vector2(element_position.x, element_position.y + element_height)
			]))
			element_position += element_step
		_update_elements_alpha()


func _update_elements_alpha():
	for index in _elements.size():
		_elements[index].modulate.a = 1 if index < current_value else 0
		if current_value > _preview_value and index < current_value and index >= _preview_value:
			_elements[index].modulate.a = preview_alpha
		if current_value < _preview_value and index >= current_value and index < _preview_value:
			_elements[index].modulate.a = preview_alpha


func _create_polygon(color: Color, vertices: PoolVector2Array) -> Polygon2D:
	var polygon = Polygon2D.new()
	polygon.color = color
	polygon.polygon = vertices
	$Polygons.add_child(polygon)
	return polygon
