extends Node
## Net (autoload): all the online co-op code. The only file that talks to GD-Sync.
## GD-Sync docs: Getting Started, Clients, Lobbies, Remote Calls (pasted by the kid).

## The status text changed (for the menu to show).
signal status_changed(text: String)
## Someone joined or left the room.
signal players_changed
## You are inside a room now (code = the 4 digits).
signal room_joined(code: String)
## Making or joining a room did not work.
signal room_failed(text: String)
## During a run: the player with hero number `index` (0 = P1) left.
signal player_left(index: int)
## The room is gone (the host left, or the connection broke).
signal room_closed

## true = local network only: no key needed, no data used. Good for testing.
## false = online through the GD-Sync servers (needs the key; the release gets it from GitHub secrets).
## F5 in Godot = local (2-window tests). The web link and downloads = online
## (browsers can't do local mode).
var LOCAL := OS.has_feature("editor")
const MAX_PLAYERS := 4

## True after GD-Sync says we are connected.
var online := false
## What is going on, in plain words.
var status := "Offline"
## Client ids of everyone in the room, in the order they joined.
var players: Array[int] = []
## The room you are in ("" = none). A room is a private GD-Sync lobby named by 4 digits.
var room_code := ""
## True while playing a co-op run (false = solo).
var in_coop := false
## The run's seed number, made by the host and sent to everyone.
var run_seed := 0
## Which hero is mine: 0 = P1, 1 = P2, ...
var my_index := 0

## What to do once we are connected (like "make a room"). Empty = nothing.
var _after_connect: Callable
## How many codes we tried (if a code is taken, we pick another one).
var _tries := 0
## The host of the room we are in (0 = not known yet).
var _host_id := 0


func _ready() -> void:
	GDSync.connected.connect(_on_connected)
	GDSync.connection_failed.connect(_on_connection_failed)
	GDSync.disconnected.connect(_on_disconnected)
	GDSync.client_joined.connect(_on_client_joined)
	GDSync.client_left.connect(_on_client_left)
	GDSync.lobby_created.connect(_on_lobby_created)
	GDSync.lobby_creation_failed.connect(_on_lobby_creation_failed)
	GDSync.lobby_joined.connect(_on_lobby_joined)
	GDSync.lobby_join_failed.connect(_on_lobby_join_failed)
	GDSync.host_changed.connect(_on_host_changed)
	# Other players may call start_game on us, but only if they are the host.
	GDSync.expose_func(start_game, ENUMS.EXPOSE_PERMISSION.HOST)
	GDSync.expose_func(restart_run, ENUMS.EXPOSE_PERMISSION.HOST)
	# Anyone may ASK the host for a move. The host checks it before doing it.
	GDSync.expose_func(request_action, ENUMS.EXPOSE_PERMISSION.ANYONE)
	# Only the host may send the game state.
	GDSync.expose_func(receive_state, ENUMS.EXPOSE_PERMISSION.HOST)


## Host: sends the new state to all the friends (not to itself).
func send_state(state: Dictionary) -> void:
	GDSync.call_func(receive_state, state)


## Runs on the friends: hands the host's state to the game to draw.
func receive_state(state: Dictionary) -> void:
	var game := get_tree().current_scene
	if game and game.has_method("apply_state"):
		game.apply_state(state)


## Client: "my hero wants to do this". Sent to the host only.
func send_action(hero_index: int, action: String) -> void:
	GDSync.call_func_on(GDSync.get_host(), request_action, hero_index, action)


## Runs on the host when a client asks for a move. The game checks if it is allowed.
func request_action(hero_index: int, action: String) -> void:
	if not is_host():
		return
	var game := get_tree().current_scene
	if game and game.has_method("do_action"):
		game.do_action(hero_index, action)


## Host only: locks the room, makes the seed, and starts the game on every client
## (also on the host itself). The hero order is the join order: the host is P1.
func host_starts_game() -> void:
	if not is_host() or players.size() < 2:
		return
	GDSync.lobby_close()  # No more joining after the start.
	GDSync.call_func_all(start_game, randi(), players)


## Host only: Play again. A new seed for everyone, and everyone starts over together.
func host_restarts() -> void:
	if is_host():
		GDSync.call_func_all(restart_run, randi())


## Runs on every client (called by the host): a new run with the host's new seed.
func restart_run(seed_number: int) -> void:
	run_seed = seed_number
	var game := get_tree().current_scene
	if game and game.has_method("start_run"):
		game.start_run(seed_number)


## Runs on every client (called by the host). Everyone gets the same seed,
## so everyone builds the same cave.
func start_game(seed_number: int, order: Array) -> void:
	players.assign(order)
	my_index = players.find(my_id())
	run_seed = seed_number
	in_coop = true
	get_tree().change_scene_to_file("res://scenes/game.tscn")


## Host: makes a private room with a random 4-digit code, then joins it.
## The first one in a room is the host.
## (Tests can pass a fixed code.)
func host_room(test_code := "") -> void:
	if not online:
		_after_connect = host_room.bind(test_code)
		go_online()
		return
	_tries += 1
	var code := test_code if test_code != "" else str(randi_range(1000, 9999))
	_set_status("Making room %s..." % code)
	GDSync.lobby_create(code, "", false, MAX_PLAYERS)  # false = private, not in any public list


## Join: goes into a friend's room by its 4-digit code.
func join_room(code: String) -> void:
	if not online:
		_after_connect = join_room.bind(code)
		go_online()
		return
	_set_status("Joining room %s..." % code)
	GDSync.lobby_join(code)


## Leaves the room you are in.
func leave_room() -> void:
	if room_code != "":
		GDSync.lobby_leave()
	room_code = ""
	players.clear()
	_host_id = 0
	_set_status("Connected" if online else "Offline")


## Starts GD-Sync. Calls the "connected" signal when it works.
func go_online() -> void:
	if online:
		return
	_set_status("Connecting...")
	if LOCAL:
		GDSync.start_local_multiplayer()
	else:
		GDSync.start_multiplayer()


## Stops GD-Sync (back to solo).
func go_offline() -> void:
	if status == "Offline":
		return  # Never started, nothing to stop.
	GDSync.stop_multiplayer()
	online = false
	in_coop = false
	room_code = ""
	players.clear()
	_host_id = 0
	_set_status("Offline")


## My own id (-1 if not connected).
func my_id() -> int:
	return GDSync.get_client_id()


## True if I am the boss of the cave (or playing solo).
func is_host() -> bool:
	return not online or GDSync.is_host()


func _on_connected() -> void:
	online = true
	_set_status("Connected (%s)" % ("local network" if LOCAL else "online"))
	if _after_connect.is_valid():
		var next := _after_connect
		_after_connect = Callable()
		next.call()


## The room exists. We have 5 seconds to join it, or GD-Sync deletes it.
func _on_lobby_created(code: String) -> void:
	_tries = 0
	GDSync.lobby_join(code)


func _on_lobby_creation_failed(code: String, error: int) -> void:
	if error == ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS and _tries < 5:
		host_room()  # That code is taken: try another one.
		return
	_tries = 0
	match error:
		ENUMS.LOBBY_CREATION_ERROR.ON_COOLDOWN:
			room_failed.emit("Wait a few seconds, then try again.")
		_:
			room_failed.emit("Couldn't make room %s (error %d)." % [code, error])


func _on_lobby_joined(code: String) -> void:
	room_code = code
	if GDSync.get_host() > 0:
		_host_id = GDSync.get_host()
	_set_status("In room %s" % code)
	room_joined.emit(code)


func _on_lobby_join_failed(code: String, error: int) -> void:
	match error:
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
			room_failed.emit("Room %s not found." % code)
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_FULL:
			room_failed.emit("Room %s is full (4 players)." % code)
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_CLOSED:
			room_failed.emit("Room %s already started." % code)
		_:
			room_failed.emit("Couldn't join room %s (error %d)." % [code, error])


func _on_connection_failed(error: int) -> void:
	online = false
	match error:
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			_set_status("Online co-op isn't ready yet (no GD-Sync key). Play Solo for now.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			_set_status("Can't connect: check your internet.")
		ENUMS.CONNECTION_FAILED.LOCAL_PORT_ERROR:
			_set_status("Can't start co-op on this device. Play Solo for now.")
		_:
			_set_status("Can't connect (error %d)." % error)


func _on_disconnected() -> void:
	online = false
	players.clear()
	room_code = ""
	_host_id = 0
	_set_status("Lost the connection.")
	players_changed.emit()
	_back_to_menu()


func _on_client_joined(client_id: int) -> void:
	if in_coop:
		return  # The room is closed after the start.
	if not players.has(client_id):
		players.append(client_id)
		players_changed.emit()


func _on_client_left(client_id: int) -> void:
	var index := players.find(client_id)
	if index == -1:
		return
	if in_coop:
		# In a run, the list keeps its order (P2 stays P2). 0 = this player left.
		players[index] = 0
		player_left.emit(index)
	else:
		players.erase(client_id)
		players_changed.emit()


## The host left. GD-Sync would pick a new host, but our host owns the whole cave,
## so the run ends for everyone (the kid's rule: no host switching in v1).
## (GD-Sync also sends this when a room first gets its host. That one is fine.)
func _on_host_changed(_i_am_host: bool, new_host_id: int) -> void:
	if _host_id <= 0 or new_host_id == _host_id:
		_host_id = new_host_id  # The first host of this room.
		return
	if room_code == "" and not in_coop:
		return
	leave_room()
	_set_status("Host left.")
	_back_to_menu()


## Ends a co-op run or room and shows the menu (it shows the status text).
func _back_to_menu() -> void:
	var was_in_game := in_coop
	in_coop = false
	if was_in_game:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	else:
		room_closed.emit()  # Still in the menu: it goes back to the first page.


func _set_status(text: String) -> void:
	status = text
	print("Net: ", text)  # Also shows in Godot's Output panel.
	status_changed.emit(text)
