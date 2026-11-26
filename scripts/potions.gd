class_name Potions
extends RefCounted
## The mystery potions for one run: their secret colors, which ones you know,
## and which ones lie on which floor.

enum Kind { HEALING, SIGHT, EMBERS }

const NAMES := {
	Kind.HEALING: "Healing",
	Kind.SIGHT: "Sight",
	Kind.EMBERS: "Embers",
}
## How many of each kind there are in one run.
const PER_RUN := {
	Kind.HEALING: 3,
	Kind.SIGHT: 2,
	Kind.EMBERS: 2,
}
## How many potions lie on floor 1, 2 and 3.
const PER_FLOOR := [2, 2, 3]
## The colors a potion can be (Ember Cave palette). Each run, 3 of them get used.
const COLORS := {
	"Orange": Color("#f2a33a"),
	"Green": Color("#7fae5a"),
	"Red": Color("#c8443a"),
	"Yellow": Color("#ffd966"),
	"Pale": Color("#e8dcc4"),
}

## For each floor, the list of potion kinds lying on it.
var by_floor: Array = []
## This run's secret: which color name each kind has. Kind -> "Orange" etc.
var color_of := {}
## Kinds you have drunk at least once this run (so you know their names).
var known := {}


## Shuffles the colors (the secret), then shuffles all 7 potions and spreads them over the floors.
func new_run(rng: RandomNumberGenerator) -> void:
	var names: Array = COLORS.keys()
	DungeonGen.shuffle(names, rng)
	color_of.clear()
	known.clear()
	for kind in Kind.values():
		color_of[kind] = names[kind]  # 3 different colors, new every run

	var all: Array = []
	for kind in PER_RUN:
		for i in PER_RUN[kind]:
			all.append(kind)
	DungeonGen.shuffle(all, rng)
	by_floor.clear()
	var at := 0
	for count in PER_FLOOR:
		by_floor.append(all.slice(at, at + count))
		at += count


## The color to tint a potion of this kind.
func tint(kind: int) -> Color:
	return COLORS[color_of[kind]]


## "Healing potion" if you know it, else "Orange potion".
func display_name(kind: int) -> String:
	if known.has(kind):
		return NAMES[kind] + " potion"
	return color_of[kind] + " potion"


## Drinking a potion teaches you its name.
func learn(kind: int) -> void:
	known[kind] = true
