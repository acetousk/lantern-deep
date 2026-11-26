extends Node
## Tune: every "feel" number in Lantern Deep, in one place.
## Change a number here, press F5, and play to feel the difference.

# --- Moving ---
## How long one step slides, in seconds. Smaller = snappier.
@export var move_time: float = 0.06
## How long something flashes red when it gets hit, in seconds.
@export var hit_flash_time: float = 0.1

# --- Player ---
## HP at the start of a run.
@export var player_hp: int = 20
## Damage you do with each hit: a random number from min to max.
@export var player_damage_min: int = 1
@export var player_damage_max: int = 3
## Chance to hit, in %, before the target's dodge is taken off.
@export var hit_chance: int = 80
## XP needed for level 2, 3 and 4.
@export var level_xp: Array[int] = [10, 25, 45]
## Waiting with no monster awake heals 1 HP every this many waits.
@export var rest_turns_per_hp: int = 10
## What each level up gives you (plus a full heal).
@export var level_hp_gain: int = 5
@export var level_damage_gain: int = 1

# --- Monsters ---
## How many monsters on floor 1, 2 and 3.
@export var monsters_per_floor: Array[int] = [4, 6, 7]
## Co-op: extra monsters on every floor for each extra player (2 players = +2, 4 players = +6).
@export var extra_monsters_per_player := 2
## Every monster: name, HP, damage (min-max), dodge %, XP it gives,
## how close you must be to wake it (tiles), and which floors it lives on.
@export var monster_types: Dictionary = {
	"slime": {"name": "Mire Slime", "hp": 4, "damage": [1, 2], "dodge": 0, "xp": 2, "wake": 4, "floors": [1, 2]},
	"moth": {"name": "Cave Moth", "hp": 3, "damage": [1, 3], "dodge": 30, "xp": 3, "wake": 4, "floors": [1, 2, 3]},
	"warden": {"name": "Bone Warden", "hp": 10, "damage": [2, 3], "dodge": 0, "xp": 6, "wake": 6, "floors": [2, 3]},
}

# --- Potions ---
## HP a Healing potion gives back.
@export var heal_amount: int = 10
## Damage an Embers potion does to you.
@export var embers_self_damage: int = 4
## Damage an Embers potion does to each monster next to you.
@export var embers_monster_damage: int = 6

# --- Seeing ---
## How many tiles your lantern lets you see.
@export var sight_radius: int = 6
## How bright the lantern glow is. 1.0 = normal.
@export var lantern_energy: float = 1.2
## How dark the cave is outside the lantern. 0 = pitch black, 1 = no darkness.
@export var cave_darkness: float = 0.5
## How bright tiles you saw before (but can't see now) look. 0 = black, 1 = full.
@export var remembered_brightness: float = 0.4

# --- Camera ---
## How close the camera is. Bigger = bigger pixels, less of the cave on screen.
@export var camera_zoom: float = 3.0

# --- The cave ---
## Size of one floor, in tiles.
@export var map_width: int = 32
@export var map_height: int = 24
## How many rooms a floor has (the 3x3 grid has room for 9).
@export var rooms_min: int = 6
@export var rooms_max: int = 9
## Smallest and biggest room size, in tiles (floor inside the walls).
@export var room_size_min: int = 3
@export var room_size_max: int = 7
## How many floors deep the cave goes.
@export var floor_count: int = 3
