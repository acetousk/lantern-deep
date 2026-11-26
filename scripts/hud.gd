class_name Hud
extends CanvasLayer
## The HUD: the info drawn on top of the game (it doesn't move with the camera).

## Sent when you click or tap a slot. 0 = slot 1.
signal slot_pressed(index: int)
## Sent for every new log message (the co-op host sends them to the friends).
signal logged(message: String)
## The end screen buttons.
signal play_again_pressed
signal menu_pressed
## A touch pad button: "move_up", "move_down", "move_left", "move_right" or "wait".
signal pad_pressed(action: String)

## The on-screen pad (bottom right), for phones and touch screens.
var pad: GridContainer
var _pad_was_visible := false

const SLOT_COUNT := 4
const BONE := Color("#e8dcc4")
const BLACK := Color("#1a1410")

@onready var stats: Label = $Stats
@onready var slot_row: HBoxContainer = $Slots
@onready var log_label: Label = $Log

## The last 3 messages, oldest first.
var log_lines: Array[String] = []

## The 4 slot boxes. Each has an Icon (the potion picture) and a Key label (1-4).
var slots: Array[TextureRect] = []


func _ready() -> void:
	_make_slots()
	_make_pad()
	# Move the slots up a bit, to make room for the names under them.
	slot_row.offset_top -= 20
	slot_row.offset_bottom -= 20


## The touch pad: 4 arrows and Wait in the middle. Only on touch screens.
## (Also when you run the game from the Godot editor, so you can test it with the mouse.)
func _make_pad() -> void:
	pad = GridContainer.new()
	pad.name = "Pad"
	pad.columns = 3
	pad.add_theme_constant_override("h_separation", 6)
	pad.add_theme_constant_override("v_separation", 6)
	pad.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	pad.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	pad.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pad.offset_right = -16
	pad.offset_bottom = -16
	# Which way each arrow points (up, left, right, down). null = an empty corner.
	var layout := [null, "move_up", null, "move_left", "wait", "move_right", null, "move_down", null]
	var arrow := {"move_up": 0.0, "move_right": PI / 2, "move_down": PI, "move_left": -PI / 2}
	for action in layout:
		if action == null:
			var gap := Control.new()
			gap.custom_minimum_size = Vector2(80, 80)
			gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pad.add_child(gap)
			continue
		var b := Button.new()
		b.custom_minimum_size = Vector2(80, 80)  # Thumb size.
		b.focus_mode = Control.FOCUS_NONE  # So the arrow keys still move you, not the buttons.
		b.modulate.a = 0.7  # A bit see-through, so you still see the cave.
		b.pressed.connect(pad_pressed.emit.bind(action))
		if action == "wait":
			b.text = "Wait"
			b.add_theme_font_size_override("font_size", 20)
			b.add_theme_color_override("font_color", BONE)
		else:
			var turn_by: float = arrow[action]
			b.draw.connect(func() -> void: _draw_arrow(b, turn_by))
		pad.add_child(b)
	pad.visible = DisplayServer.is_touchscreen_available() or OS.has_feature("editor")
	add_child(pad)


## A bone-white triangle in the middle of the button, turned to point the right way.
func _draw_arrow(b: Button, turn_by: float) -> void:
	var c := b.size / 2
	var points := PackedVector2Array()
	for p in [Vector2(0, -18), Vector2(16, 12), Vector2(-16, 12)]:
		points.append(c + p.rotated(turn_by))
	b.draw_colored_polygon(points, BONE)


## Shows HP, level, XP and floor at the top left.
## `waiting` is like "Waiting for P2" (empty = nobody to wait for).
func show_stats(player: Player, floor_num: int, waiting := "") -> void:
	var xp_text := "%d" % player.xp
	if player.level - 1 < Tune.level_xp.size():
		xp_text += "/%d" % Tune.level_xp[player.level - 1]  # XP needed for the next level
	stats.text = "P%d    HP %d/%d    Lv %d  XP %s    Floor %d" % [
		player.number, player.hp, player.max_hp, player.level, xp_text, floor_num]
	if waiting != "":
		stats.text += "    " + waiting


## Shows the potions you carry in the slots. Empty slots show nothing.
## Hover a slot (mouse) to see its name.
func show_slots(carried: Array[int], potions: Potions) -> void:
	var potion_tex: Texture2D = load("res://art/potion.png")
	for i in SLOT_COUNT:
		var icon: TextureRect = slots[i].get_node("Icon")
		var name_label: Label = slots[i].get_node("Name")
		if i < carried.size():
			var kind := carried[i]
			icon.texture = potion_tex
			icon.self_modulate = potions.tint(kind)
			slots[i].tooltip_text = potions.display_name(kind)
			# Under the slot: the real name once someone drank this kind, else the color + "?".
			name_label.text = potions.NAMES[kind] if potions.known.has(kind) else potions.color_of[kind] + "?"
		else:
			icon.texture = null
			slots[i].tooltip_text = ""
			name_label.text = ""


func _on_slot_input(event: InputEvent, index: int) -> void:
	var clicked: bool = event is InputEventMouseButton and event.pressed \
		and event.button_index == MOUSE_BUTTON_LEFT
	var tapped: bool = event is InputEventScreenTouch and event.pressed
	if clicked or tapped:
		slot_pressed.emit(index)


## The end screen: the cave goes dim, a big title ("You win!" or "You died"),
## the run's stats, and 2 buttons. can_restart = false: a co-op friend
## waits for the host to press Play again.
func show_end(title: String, stats_text: String, can_restart: bool) -> void:
	hide_end()
	_pad_was_visible = pad.visible
	pad.visible = false  # No moving on the end screen.
	var shade := ColorRect.new()
	shade.name = "EndShade"
	shade.color = Color(BLACK, 0.6)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	show_banner(title)
	$Banner.offset_bottom = -220  # Moves the title up, above the panel.

	var panel := VBoxContainer.new()
	panel.name = "EndPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.add_theme_constant_override("separation", 16)
	add_child(panel)
	var info := Label.new()
	info.name = "EndStats"
	info.text = stats_text
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 28)
	info.add_theme_color_override("font_color", BONE)
	info.add_theme_color_override("font_outline_color", BLACK)
	info.add_theme_constant_override("outline_size", 8)
	panel.add_child(info)
	var again: Control
	if can_restart:
		again = _big_button("Play again", play_again_pressed.emit)
	else:
		again = Label.new()
		again.text = "Waiting for the host..."
		again.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		again.add_theme_font_size_override("font_size", 24)
		again.add_theme_color_override("font_color", BONE)
	panel.add_child(again)
	var menu := _big_button("Menu", menu_pressed.emit)
	panel.add_child(menu)
	(again if again is Button else menu).grab_focus()  # Keyboard and gamepad can press it right away.


## Removes the end screen (for Play again).
func hide_end() -> void:
	if has_node("EndPanel"):
		pad.visible = _pad_was_visible
	for n in ["EndShade", "Banner", "EndPanel"]:
		if has_node(n):
			var node := get_node(n)
			remove_child(node)  # Right away, so has_node("Banner") is false at once.
			node.queue_free()


func _big_button(text: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 64)  # Big enough to tap on a phone.
	b.add_theme_font_size_override("font_size", 28)
	b.add_theme_color_override("font_color", BONE)
	b.add_theme_color_override("font_focus_color", Color("#ffd966"))
	b.add_theme_color_override("font_hover_color", Color("#ffd966"))
	b.pressed.connect(Sfx.play.bind("click"))
	b.pressed.connect(on_press)
	return b


## Big text in the middle of the screen, like "You win!".
func show_banner(text: String) -> void:
	var banner := Label.new()
	banner.name = "Banner"
	banner.text = text
	banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.add_theme_color_override("font_color", Color("#ffd966"))  # flame yellow
	banner.add_theme_color_override("font_outline_color", BLACK)
	banner.add_theme_constant_override("outline_size", 12)
	banner.add_theme_font_size_override("font_size", 72)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(banner)


## Adds a message to the log. Only the newest 3 stay; the newest is at the bottom.
func add_log(message: String) -> void:
	log_lines.append(message)
	if log_lines.size() > 3:
		log_lines.pop_front()
	log_label.text = "\n".join(log_lines)
	logged.emit(message)


## Builds the 4 slot boxes at the bottom of the screen.
func _make_slots() -> void:
	var box_tex: Texture2D = load("res://art/ui/slot.svg")
	for i in SLOT_COUNT:
		var box := TextureRect.new()
		box.texture = box_tex
		box.custom_minimum_size = Vector2(64, 64)
		box.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		box.mouse_filter = Control.MOUSE_FILTER_STOP  # Clicking or tapping a slot drinks it.
		box.gui_input.connect(_on_slot_input.bind(i))

		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 12
		icon.offset_top = 12
		icon.offset_right = -12
		icon.offset_bottom = -12
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(icon)

		var key := Label.new()
		key.name = "Key"
		key.text = str(i + 1)
		key.position = Vector2(6, 2)
		key.add_theme_color_override("font_color", BONE)
		key.add_theme_color_override("font_outline_color", BLACK)
		key.add_theme_constant_override("outline_size", 4)
		key.add_theme_font_size_override("font_size", 14)
		box.add_child(key)

		# The potion's name, just under the box (phones can't hover for the tooltip).
		var potion_name := Label.new()
		potion_name.name = "Name"
		potion_name.position = Vector2(-8, 64)
		potion_name.size = Vector2(80, 20)
		potion_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		potion_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
		potion_name.add_theme_color_override("font_color", BONE)
		potion_name.add_theme_color_override("font_outline_color", BLACK)
		potion_name.add_theme_constant_override("outline_size", 4)
		potion_name.add_theme_font_size_override("font_size", 13)
		box.add_child(potion_name)

		slot_row.add_child(box)
		slots.append(box)
