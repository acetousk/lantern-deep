extends Control
## The first screen: Solo, Host or Join. Then the room page (code + players).
## Works with mouse, touch, keyboard (arrows + Enter) and gamepad (d-pad + A).

const GAME_SCENE := "res://scenes/game.tscn"
const YELLOW := Color("#ffd966")
const BONE := Color("#e8dcc4")
const ROCK := Color("#6b5a4e")
const BLACK := Color("#1a1410")
## Hero colors, the same as in the game (P1 normal, P2 green, P3 orange, P4 yellow).
const HERO_COLORS := [BONE, Color("#7fae5a"), Color("#f2a33a"), YELLOW]

## The column in the middle of the screen. Each page fills it again.
var box: VBoxContainer
var status_label: Label
## On the room page: the list of players.
var players_box: VBoxContainer
## On the join page: the digits typed so far, and the label that shows them.
var typed := ""
var code_label: Label
## On the room page, for the host only.
var start_button: Button


func _ready() -> void:
	box = VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	Net.status_changed.connect(func(text: String) -> void: status_label.text = text)
	Net.room_joined.connect(func(_code: String) -> void: _show_room())
	Net.room_failed.connect(func(text: String) -> void: status_label.text = text)
	Net.players_changed.connect(_refresh_players)
	Net.room_closed.connect(_show_main)  # The status line says why.
	_show_main()


# --- Pages ---

func _show_main() -> void:
	_clear()
	box.add_child(_label("Lantern Deep", 64, YELLOW))
	var solo := _button("Solo", _on_solo)
	box.add_child(solo)
	box.add_child(_button("Host a room", _on_host))
	box.add_child(_button("Join a room", _on_join))
	_add_status()
	solo.grab_focus()  # So keyboard and gamepad can pick a button right away.


## The room page: the big code to tell your friends, and who is in.
func _show_room() -> void:
	_clear()
	box.add_child(_label("Room code", 28, BONE))
	box.add_child(_label(Net.room_code, 96, YELLOW))
	box.add_child(_label("Tell your friends this code.", 20, ROCK))
	players_box = VBoxContainer.new()
	box.add_child(players_box)
	var back := _button("Back", _on_back)
	if Net.is_host():
		start_button = _button("Start", Net.host_starts_game)
		box.add_child(start_button)
	else:
		box.add_child(_label("Waiting for the host to start...", 20, BONE))
	box.add_child(back)
	_add_status()
	_refresh_players()
	if start_button:
		start_button.grab_focus()
	else:
		back.grab_focus()


## The join page: a number pad to type the 4-digit code.
## Tap the buttons, or type with the number keys (Backspace, Enter).
func _show_join() -> void:
	_clear()
	typed = ""
	box.add_child(_label("Type the room code", 28, BONE))
	code_label = _label("", 96, YELLOW)
	box.add_child(code_label)
	_show_typed()
	var pad := GridContainer.new()
	pad.columns = 3
	pad.add_theme_constant_override("h_separation", 8)
	pad.add_theme_constant_override("v_separation", 8)
	for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "Erase", "0", "Join"]:
		var b: Button
		match key:
			"Erase":
				b = _button(key, _on_erase)
			"Join":
				b = _button(key, _on_join_code)
			_:
				b = _button(key, _on_digit.bind(key))
		b.custom_minimum_size = Vector2(104, 72)
		pad.add_child(b)
	var center := CenterContainer.new()
	center.add_child(pad)
	box.add_child(center)
	box.add_child(_button("Back", _on_back))
	_add_status()
	pad.get_child(0).grab_focus()


func _show_typed() -> void:
	code_label.text = typed + "_".repeat(4 - typed.length())


func _on_digit(digit: String) -> void:
	if typed.length() < 4:
		typed += digit
		_show_typed()


func _on_erase() -> void:
	typed = typed.left(-1)
	_show_typed()


func _on_join_code() -> void:
	if typed.length() < 4:
		status_label.text = "The code has 4 numbers."
		return
	Net.join_room(typed)


## Number keys, Backspace and Enter also work on the join page.
func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(code_label) or not (event is InputEventKey and event.pressed):
		return
	var key: int = event.physical_keycode
	if key >= KEY_0 and key <= KEY_9:
		_on_digit(str(key - KEY_0))
	elif key >= KEY_KP_0 and key <= KEY_KP_9:
		_on_digit(str(key - KEY_KP_0))
	elif key == KEY_BACKSPACE:
		_on_erase()
	else:
		return
	get_viewport().set_input_as_handled()


func _refresh_players() -> void:
	if not is_instance_valid(players_box):
		return
	for child in players_box.get_children():
		child.queue_free()
	for i in Net.players.size():
		var you := "  (you)" if Net.players[i] == Net.my_id() else ""
		players_box.add_child(_label("P%d%s" % [i + 1, you], 28, HERO_COLORS[i]))
	if start_button:
		start_button.disabled = Net.players.size() < 2  # Co-op needs a friend. Alone? Use Solo.
		start_button.text = "Start" if not start_button.disabled else "Start (need 2 players)"


# --- Buttons ---

func _on_solo() -> void:
	Net.go_offline()
	Net.in_coop = false
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_host() -> void:
	Net.host_room()


func _on_join() -> void:
	_show_join()


func _on_back() -> void:
	Net.leave_room()
	_show_main()


# --- Helpers ---

func _clear() -> void:
	for child in box.get_children():
		child.queue_free()
	players_box = null
	code_label = null
	start_button = null


func _add_status() -> void:
	status_label = _label(Net.status, 20, ROCK)
	box.add_child(status_label)


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", BLACK)
	l.add_theme_constant_override("outline_size", 8)
	return l


func _button(text: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 64)  # Big enough to tap on a phone.
	b.add_theme_font_size_override("font_size", 28)
	b.add_theme_color_override("font_color", BONE)
	b.add_theme_color_override("font_focus_color", YELLOW)
	b.add_theme_color_override("font_hover_color", YELLOW)
	b.pressed.connect(Sfx.play.bind("click"))
	b.pressed.connect(on_press)
	return b
