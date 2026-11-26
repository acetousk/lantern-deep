class_name DungeonGen
extends RefCounted
## Makes one cave floor.
## The floor is split into a 3x3 grid (like tic-tac-toe).
## Some squares of the grid get a room of random size.

enum Tile { WALL, FLOOR, STAIRS }

const GRID := 3

var width: int
var height: int
## One number per tile (see Tile). Row by row, left to right.
var tiles: PackedByteArray
## Which grid square (Vector2i 0..2, 0..2) has which room (Rect2i).
var rooms: Dictionary = {}
## Where the player starts.
var start: Vector2i
## The stairs down (floors 1-2) or the relic spot (last floor).
var goal: Vector2i
## How many caves we threw away because the goal couldn't be reached.
var retries := 0


## Makes a brand new floor. Same rng seed = same floor.
## has_stairs = false on the last floor: the goal is the relic spot instead.
func generate(rng: RandomNumberGenerator, has_stairs := true) -> void:
	width = Tune.map_width
	height = Tune.map_height
	retries = 0
	while true:
		_build(rng)
		if _can_reach(start, goal) or retries >= 100:
			break
		retries += 1  # The paint didn't reach the goal: throw this cave away.
	if has_stairs:
		set_tile(goal, Tile.STAIRS)


func _build(rng: RandomNumberGenerator) -> void:
	tiles = PackedByteArray()
	tiles.resize(width * height)
	tiles.fill(Tile.WALL)
	rooms.clear()
	_place_rooms(rng)
	_join_rooms(rng)
	_place_start_and_goal(rng)


func get_tile(p: Vector2i) -> int:
	if p.x < 0 or p.y < 0 or p.x >= width or p.y >= height:
		return Tile.WALL
	return tiles[p.y * width + p.x]


func set_tile(p: Vector2i, t: int) -> void:
	tiles[p.y * width + p.x] = t


## The floor as text: # = wall, . = floor, > = stairs, @ = start, * = goal. Handy for checking.
func to_text() -> String:
	var marks := {Tile.WALL: "#", Tile.FLOOR: ".", Tile.STAIRS: ">"}
	var out := ""
	for y in height:
		for x in width:
			var p := Vector2i(x, y)
			if p == start:
				out += "@"
			elif p == goal and get_tile(p) != Tile.STAIRS:
				out += "*"
			else:
				out += marks[get_tile(p)]
		out += "\n"
	return out


# --- Start and goal ---

## Start in a random room. Put the goal in the room farthest away on the grid.
func _place_start_and_goal(rng: RandomNumberGenerator) -> void:
	var cells: Array = rooms.keys()
	var start_cell: Vector2i = cells[rng.randi_range(0, cells.size() - 1)]
	var goal_cell := start_cell
	for c in cells:
		if _grid_dist(start_cell, c) > _grid_dist(start_cell, goal_cell):
			goal_cell = c
	start = _random_spot(rng, rooms[start_cell])
	goal = _random_spot(rng, rooms[goal_cell])


## A random floor tile in any room that isn't the start, the goal, or in `taken`.
func random_free_spot(rng: RandomNumberGenerator, taken: Dictionary) -> Vector2i:
	var cells: Array = rooms.keys()
	while true:
		var room: Rect2i = rooms[cells[rng.randi_range(0, cells.size() - 1)]]
		var p := _random_spot(rng, room)
		if p != start and p != goal and not taken.has(p):
			return p
	return start  # Never reached.


func _random_spot(rng: RandomNumberGenerator, room: Rect2i) -> Vector2i:
	return Vector2i(
		rng.randi_range(room.position.x, room.end.x - 1),
		rng.randi_range(room.position.y, room.end.y - 1))


# --- Flood fill ---

## Pours "paint" on `from` and lets it spread to every floor tile it touches
## (up, down, left, right). True if the paint reaches `to`.
func _can_reach(from: Vector2i, to: Vector2i) -> bool:
	var seen := {from: true}
	var todo: Array[Vector2i] = [from]
	while not todo.is_empty():
		var p: Vector2i = todo.pop_back()
		if p == to:
			return true
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var n: Vector2i = p + dir
			if not seen.has(n) and get_tile(n) != Tile.WALL:
				seen[n] = true
				todo.append(n)
	return false


# --- Rooms ---

func _place_rooms(rng: RandomNumberGenerator) -> void:
	# All 9 grid squares, in a random order.
	var cells: Array[Vector2i] = []
	for y in GRID:
		for x in GRID:
			cells.append(Vector2i(x, y))
	shuffle(cells, rng)

	# Keep the first 6-9 of them, and put a room in each.
	var count := rng.randi_range(Tune.rooms_min, mini(Tune.rooms_max, GRID * GRID))
	for i in count:
		var room := _make_room(rng, cells[i])
		rooms[cells[i]] = room
		_carve(room)


## A room of random size at a random spot inside its grid square.
## It always keeps 1 tile of wall around it, so rooms never touch.
func _make_room(rng: RandomNumberGenerator, cell: Vector2i) -> Rect2i:
	var cell_w := int(width / float(GRID))
	var cell_h := int(height / float(GRID))
	var max_w := mini(Tune.room_size_max, cell_w - 2)
	var max_h := mini(Tune.room_size_max, cell_h - 2)
	var w := rng.randi_range(mini(Tune.room_size_min, max_w), max_w)
	var h := rng.randi_range(mini(Tune.room_size_min, max_h), max_h)
	var x := cell.x * cell_w + rng.randi_range(1, cell_w - 1 - w)
	var y := cell.y * cell_h + rng.randi_range(1, cell_h - 1 - h)
	return Rect2i(x, y, w, h)


func _carve(room: Rect2i) -> void:
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			set_tile(Vector2i(x, y), Tile.FLOOR)


# --- Hallways ---

## Joins every room into one cave:
## start with 1 room, then keep joining the closest room that isn't joined yet.
## Then add 1-2 extra hallways, so there is sometimes more than one way around.
func _join_rooms(rng: RandomNumberGenerator) -> void:
	var cells: Array = rooms.keys()
	shuffle(cells, rng)
	var joined: Array = [cells.pop_back()]
	var links := {}

	while not cells.is_empty():
		var best_a: Vector2i
		var best_b: Vector2i
		var best_dist := 999
		for a in joined:
			for b in cells:
				var dist := _grid_dist(a, b)
				if dist < best_dist:
					best_dist = dist
					best_a = a
					best_b = b
		_dig_hallway(rng, rooms[best_a], rooms[best_b])
		links[_link_key(best_a, best_b)] = true
		joined.append(best_b)
		cells.erase(best_b)

	# Extra hallways between rooms that sit side by side on the grid.
	var extras := rng.randi_range(1, 2)
	var pairs: Array = []
	for a in rooms:
		for b in rooms:
			if a < b and _grid_dist(a, b) == 1 and not links.has(_link_key(a, b)):
				pairs.append([a, b])
	shuffle(pairs, rng)
	for i in mini(extras, pairs.size()):
		_dig_hallway(rng, rooms[pairs[i][0]], rooms[pairs[i][1]])


## An L-shaped hallway, 1 tile wide, from the middle of one room to the middle of another.
func _dig_hallway(rng: RandomNumberGenerator, from: Rect2i, to: Rect2i) -> void:
	var a := from.get_center()
	var b := to.get_center()
	var corner := Vector2i(b.x, a.y) if rng.randi() % 2 == 0 else Vector2i(a.x, b.y)
	_dig_line(a, corner)
	_dig_line(corner, b)


func _dig_line(a: Vector2i, b: Vector2i) -> void:
	var step := (b - a).sign()
	var p := a
	set_tile(p, Tile.FLOOR)
	while p != b:
		p += step
		set_tile(p, Tile.FLOOR)


func _grid_dist(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


func _link_key(a: Vector2i, b: Vector2i) -> String:
	return str(a, b) if a < b else str(b, a)


## Mixes up an array using our rng (so a seed always gives the same cave).
static func shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
