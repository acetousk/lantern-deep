extends Node
## Sfx (autoload): plays the sound effects from sfx/ (made by tools/make_sfx.py).
## Use: Sfx.play("hit")
## Silent until the first click, tap, key or button press. Web browsers block
## sound before that, and a game shouldn't make noise before you touch it.

const NAMES := ["step", "hit", "miss", "hurt", "die", "level_up", "drink", "stairs", "relic", "lose", "click"]
## How many sounds can play at the same time.
const VOICES := 6

## True after the first click, tap, key or button press.
var unlocked := false
## The last sound asked for (the tests check this).
var last := ""
var _sounds := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for n in NAMES:
		_sounds[n] = load("res://sfx/%s.wav" % n)
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)


func _input(event: InputEvent) -> void:
	if not unlocked and event.is_pressed() and not event.is_echo():
		if event is InputEventMouseButton or event is InputEventScreenTouch \
				or event is InputEventKey or event is InputEventJoypadButton:
			unlocked = true


## Plays a sound by name. Several at once is fine (up to VOICES).
func play(sound_name: String) -> void:
	last = sound_name  # For the tests (they can't listen).
	if not unlocked or not _sounds.has(sound_name):
		return
	var p := _players[_next]
	_next = (_next + 1) % VOICES
	p.stream = _sounds[sound_name]
	p.play()
