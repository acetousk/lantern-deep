class_name Fov
extends RefCounted
## Field of view: which tiles the player can see right now.
## Uses "shadowcasting": we split the view around the player into 8 pie slices.
## In each slice we scan outward row by row. A wall casts a shadow,
## and every tile in that shadow stays hidden, like a flashlight in a real cave.

## For each of the 8 slices: how to turn the slice's (dx, dy) into map directions.
const MULT := [
	[1, 0, 0, -1, -1, 0, 0, 1],
	[0, 1, -1, 0, 0, -1, 1, 0],
	[0, 1, 1, 0, 0, -1, -1, 0],
	[1, 0, 0, 1, -1, 0, 0, -1],
]


## Returns a Dictionary with every visible tile as a key.
static func compute(gen: DungeonGen, origin: Vector2i, radius: int) -> Dictionary:
	var seen := {origin: true}
	for slice in 8:
		_scan(gen, origin, radius, 1, 1.0, 0.0,
			MULT[0][slice], MULT[1][slice], MULT[2][slice], MULT[3][slice], seen)
	return seen


## Scans one slice, from row `row` outward.
## `start` and `end` are the slopes of the part of the slice that is still lit.
static func _scan(gen: DungeonGen, origin: Vector2i, radius: int, row: int,
		start: float, end: float, xx: int, xy: int, yx: int, yy: int, seen: Dictionary) -> void:
	if start < end:
		return
	var radius_sq := radius * radius
	var new_start := 0.0
	for j in range(row, radius + 1):
		var dx := -j - 1
		var dy := -j
		var blocked := false
		while dx <= 0:
			dx += 1
			var p := Vector2i(origin.x + dx * xx + dy * xy, origin.y + dx * yx + dy * yy)
			var left_slope := (dx - 0.5) / (dy + 0.5)
			var right_slope := (dx + 0.5) / (dy - 0.5)
			if start < right_slope:
				continue
			elif end > left_slope:
				break
			if dx * dx + dy * dy <= radius_sq:
				seen[p] = true
			var is_wall := gen.get_tile(p) == DungeonGen.Tile.WALL
			if blocked:
				if is_wall:
					new_start = right_slope  # Still in the shadow.
					continue
				blocked = false  # Out of the shadow: light again.
				start = new_start
			elif is_wall and j < radius:
				# A wall: scan the lit part before it, then start a shadow.
				blocked = true
				_scan(gen, origin, radius, j + 1, start, left_slope, xx, xy, yx, yy, seen)
				new_start = right_slope
		if blocked:
			break
