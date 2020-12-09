class_name DamageEffect
extends Effect


var damage: int
var targets: Array


func _init(level, tile: LevelTile, damage: int).(level, tile):
	self.damage = damage
	self.targets = level.get_targets_at_tile(tile)
	for target in targets:
		target.preview_health -= damage


func preview():
	tile.damage_label.text = str(damage)
	for target in targets:
		target.show_preview_health()


func reset():
	tile.damage_label.text = ""
	for target in targets:
		target.hide_preview_health()


func cause():
	for target in targets:
		target.health -= damage
