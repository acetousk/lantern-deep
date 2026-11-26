# PLAN

## This week
First playable of Lantern Deep: 1–4 players online co-op (GD-Sync), start → play → win or lose → play again, with sound, on all 4 platforms.
Before N2: the kid pastes the GD-Sync **Clients** docs page and finds out if GD-Sync works on Web. The parent makes sure the GD-Sync key file is never committed.

## Cards
| ✓ | ID | Input | Output | Done when |
|---|---|---|---|---|
| ✓ | G1 Design + scope | The kid's answers | `DESIGN.md`, `PLAN.md` | The kid says DESIGN.md matches the game in their head |
| ✓ | G2 Core loop (15 steps) | DESIGN.md, palette | `tools/make_sprites.py`, sprites, `scripts/tune.gd`, dungeon generator, player, camera, fog, lantern, stairs | You walk through 3 new floors per run in the dark with the lantern, and the stairs can always be reached |
| ✓ | G3 Goal (8 steps) | G2 | HUD, log, potions (random colors, 3 effects), relic on floor 3, win | You find and drink potions, grab the relic, and see "You win" |
| ✓ | G4 Pressure (10 steps) | G3 | Turn manager, 3 monsters, sleep/wake, bump combat, hit flash, XP + level up, wait + heal, lose | Monsters wake, fight you, and can kill you |
| ✓ | N1 Team cave (5 steps) | G4 | One seed per run, 1–4 heroes, team turns, monsters chase the nearest hero, shared vision, win together, dead heroes watch | 2 heroes on 1 PC (Tab switches, test only) play a full run, and monsters only move after both heroes acted |
| ✓ | N2 Lobby (6 steps + kid installs GD-Sync) | N1, GD-Sync plugin, docs | `scripts/net.gd`, menu (Solo / Host / Join), 4-digit room code, number pad, Start | 2 game windows on 1 PC (local mode) join the same room and start the same cave |
|   | N3 Online turns (6 steps) — steps 11–15 ✓, 16 waits for the GD-Sync key | N2 | Moves go to the host, the host sends state, host-only monster turns, synced potions/stairs/relic/death, someone leaving | 2 windows play a full run together, and it works on Web and Android |
| ✓ | G5 Flow + sound + touch (9 steps): 1 end panel + stats, 2 solo play again, 3 co-op play again + Menu, 4 touch pad, 5 tap a tile, 6 `tools/make_sfx.py`, 7 `Sfx` + click, 8 game sounds (synced), 9 kid plays 3 games + names a fix | G4, N3 | `game.gd`, `hud.gd`, `net.gd`, `menu.gd`, `sfx.gd`, `tools/make_sfx.py`, `sfx/`, `project.godot`, `CREDITS.md` | A full game works 3 times in a row with sound, by keyboard, gamepad and touch, solo and in 2 windows |
|   | G6 Ship (5 steps): 1 potion names under the slots ("Red?" → "Healing"), 2 title + icon, 3 speed check (web, phone) — moved to after the release, on the real web link and the kid's phone, 4 `CHANGELOG.md` + `README.md`, 5 ask to tag `v0.1.0` | G5 | `hud.gd`, `tools/print_cave.gd`, `project.godot`, `icon.svg`, `CHANGELOG.md`, `README.md`, `PLAN.md`, `PLAYTEST.md` | Potion names show on every platform, title + icon say Lantern Deep, it runs smoothly on web (and phone if possible), and you are asked to tag `v0.1.0` |

## Bugs
- B1 (v0.1.0): in a wide window the camera stops at the cave edges, so the cave sits on the right and the hero isn't centered. Fix: no camera limits, the camera always centers on the hero. Output: `game.gd`, `tools/print_cave.gd`, `CHANGELOG.md`. Done when: the hero is in the middle on the web link → ask to tag `v0.1.1`. ✓
- B2 (v0.1.1): on the web link, Host a room says "Can't connect (error 2)": browsers can't do local mode. Fix: F5 = local, releases = online; plain messages when there's no key. Output: `net.gd`, `tools/print_cave.gd`, `CHANGELOG.md`. Done when: plain message on the web → ask to tag `v0.1.2`. Then, when the keys are GitHub secrets: a new release, the kid + friend play 1 floor online (finishes N3 step 16).
