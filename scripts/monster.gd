class_name Monster
extends Sprite2D
## One monster in the cave. Its numbers come from Tune.monster_types.

const DIRS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

## "slime", "moth" or "warden".
var type: String
## Its row from Tune.monster_types (name, hp, damage, dodge, xp, wake, floors).
var info: Dictionary
var hp: int
## Which tile it is on.
var cell: Vector2i
## Monsters sleep until you come close.
var awake := false
## Its number on this floor (0, 1, 2...). Same on every player's game, so the
## host can say "monster 3 moved" and everyone knows which one.
var id := 0
## The game, so the monster can ask where it may walk.
var game: Node


## Sets up a new monster of this type on this tile.
func setup(monster_type: String, at: Vector2i) -> void:
	type = monster_type
	info = Tune.monster_types[type]
	hp = info.hp
	texture = load("res://art/%s.png" % type)
	cell = at
	position = Player.cell_to_pos(at)


## Its 1 action per turn while awake.
## game.path_dist tells, for each tile, how many steps it is from the player.
## The monster steps to the next tile that is 1 step closer, if that tile is free.
func take_turn() -> void:
	var here: int = game.path_dist.get(cell, 999)
	if here <= 1:
		game.monster_attacks(self)  # Next to you: it attacks instead of moving.
		return
	var best := cell
	var best_dist := here
	for dir in DIRS:
		var next: Vector2i = cell + dir
		var d: int = game.path_dist.get(next, 999)
		if d < best_dist and game.is_free(next):
			best = next
			best_dist = d
	if best != cell:
		slide_to(best)


## (Co-op friends also call this, when the host says the monster moved.)
func slide_to(target: Vector2i) -> void:
	cell = target
	var tween := create_tween()
	tween.tween_property(self, "position", Player.cell_to_pos(cell), Tune.move_time)
