# Changelog

## v0.1.2 (2026-11-25)
- Fix: the web link and downloads use online co-op (browsers can't do local mode). Until the GD-Sync key is set up, Host and Join say "Online co-op isn't ready yet" instead of "error 2". Godot's F5 still uses local mode for 2-window tests.

## v0.1.1 (2026-11-25)
- Fix: the camera always keeps your hero in the middle of the screen. Before, in a wide window, the cave sat on the right and half the screen was empty.

## v0.1.0 (2026-11-25): first playable
- 3 cave floors, made new every run from a seed. Fog of war and a lantern light.
- Turn-based moves and bump-to-attack fights. Monsters: Mire Slime, Cave Moth, Bone Warden.
- XP and level ups. Rest by waiting.
- 3 potion kinds with random colors each run: Healing, Sight, Embers. Their names show under the slots once someone has drunk one.
- Win: grab the Ember Relic on floor 3. Lose: HP 0. The end screen shows your stats, with Play again and Menu buttons.
- Co-op for 2–4 players with a 4-digit room code: shared cave, shared vision, the team goes down the stairs together, ghosts watch their friends.
- Keyboard, gamepad and touch (an on-screen pad, or tap a tile).
- 11 sounds made by `tools/make_sfx.py`. No sound before the first click or tap.
- Known: co-op only works on 1 computer for now (local mode). Online co-op comes when the GD-Sync key is set up.

## v0.0.1
- Pipeline test.
