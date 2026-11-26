class_name Player
extends Sprite2D
## The lantern guy. Moves 1 tile at a time on the grid, with a short slide.

## Sent after each step, when the slide is done.
signal moved(cell: Vector2i)
## Sent when you skip a turn (Space / A).
signal waited
## Sent when you walk into a monster: that's an attack.
signal bumped(target: Vector2i)
## Sent when you press a key: "I want to do this" (like "move_left" or "wait").
signal asked(action: String)

const TILE := 16
const DIRS := {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
}

## Which tile the player is on.
var cell: Vector2i
## The floor we walk on (to know where the walls are).
var gen: DungeonGen
## True while sliding. No new step until the slide is done.
var busy := false
## False when the run is over (win or lose): no more moving.
var active := true
## True after this hero died (a ghost that watches). Not true after a win.
var ghost := false
## True for the hero your keys move. The other heroes ignore your keys.
var controlled := true
## Hero number: 1 to 4 (P1-P4).
var number := 1
## True after this hero acted this round. It waits until its friends acted too.
var done := false
## Waits in a row with no monster awake. Every 10 = +1 HP.
var rest_count := 0

# --- Stats ---
var max_hp := Tune.player_hp
var hp := Tune.player_hp
var level := 1
var xp := 0
## Extra damage from leveling up.
var damage_bonus := 0
## Asks "is there a monster on this tile?" (set by the game).
var has_monster: Callable = func(_p: Vector2i) -> bool: return false
## Asks "is another hero on this tile?" (set by the game). Friends block you.
var has_friend: Callable = func(_p: Vector2i) -> bool: return false
## Potions you carry (Potions.Kind), up to 4.
var potions: Array[int] = []


## Puts the player on a tile right away (no slide).
func place(c: Vector2i) -> void:
	cell = c
	position = cell_to_pos(c)


static func cell_to_pos(c: Vector2i) -> Vector2:
	return Vector2(c * TILE) + Vector2(TILE, TILE) / 2.0


## Your key press does not move you right away. It asks the game first
## (in co-op the game asks the host). The host then calls do().
func _unhandled_input(event: InputEvent) -> void:
	if busy or not active or not controlled or done:
		return
	for action in ["wait"] + DIRS.keys():
		# true = holding the key keeps walking
		if event.is_action_pressed(action, true):
			get_viewport().set_input_as_handled()
			asked.emit(action)
			return


## Does an action: "wait", or a move like "move_left".
func do(action: String) -> void:
	if action == "wait":
		waited.emit()
	elif DIRS.has(action):
		try_move(DIRS[action])


func try_move(dir: Vector2i) -> void:
	var target := cell + dir
	if gen.get_tile(target) == DungeonGen.Tile.WALL:
		return  # Walls block you.
	if has_monster.call(target):
		bumped.emit(target)  # Walking into a monster = attacking it.
		return
	if has_friend.call(target):
		return  # A friend is standing there.
	slide_to(target).finished.connect(func() -> void: moved.emit(cell))


## Slides to a tile. (Co-op clients only use this: the host already decided the move.)
func slide_to(target: Vector2i) -> Tween:
	cell = target
	busy = true
	var tween := create_tween()
	tween.tween_property(self, "position", cell_to_pos(cell), Tune.move_time)
	tween.finished.connect(func() -> void: busy = false)
	return tween
