extends Node
## Tests the online code in local mode (no key needed).
## Run 2 at once:
##   godot --headless tools/net_test.tscn -- host 4321
##   godot --headless tools/net_test.tscn -- join 4321
## Or just "host" alone for a quick host test.

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var mode: String = args[0] if args.size() > 0 else "host"
	var code: String = args[1] if args.size() > 1 else ""
	Net.room_joined.connect(func(c: String) -> void:
		print(mode, " test: in room ", c, ", me ", Net.my_id(), ", host: ", Net.is_host()))
	Net.room_failed.connect(func(text: String) -> void: print(mode, " test FAILED: ", text))
	Net.players_changed.connect(func() -> void: print(mode, " test: players now ", Net.players.size()))
	if mode == "join":
		Net.join_room(code)
	else:
		Net.host_room(code)
	var wait_s := 25.0 if mode == "host" else 12.0  # The host stays open longer, for the joiner.
	await get_tree().create_timer(wait_s).timeout
	print(mode, " test: after ", wait_s, " s: room '", Net.room_code, "', ", Net.players.size(), " players")
	Net.leave_room()
	get_tree().quit()
