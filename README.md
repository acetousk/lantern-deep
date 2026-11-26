# Lantern Deep

You carry a lantern down a dark cave, floor by floor, to grab the Ember Relic.

A 2D turn-based cave crawler for 1–4 players, made with Godot 4.7.2.

## How to play
- Every move is one turn. When every hero has moved, the awake monsters move.
- Bump into a monster to attack it. Kills give XP, and level ups heal you.
- Potions have random colors each run. Drink one to learn its name.
- Find the stairs on floors 1 and 2. Grab the Ember Relic on floor 3 to win.
- If your HP reaches 0, the run is over. Press Play again for a new cave.

## Controls
| Action | Keyboard | Gamepad | Touch |
|---|---|---|---|
| Move | Arrows / WASD | D-pad | Tap the next tile, or the on-screen pad |
| Wait | Space | A | Wait button |
| Drink | 1–4 | — | Tap a slot |

## Co-op
Pick **Host a room** and tell your friends the 4-digit code. They pick **Join a room** and type it in. The host presses Start.
Online rooms in the web, phone, and PC builds need this repo's GD-Sync keys (the kit's `online` skill). Until then, rooms work only inside Godot (2 windows, local mode).

## Play
- **Web:** https://acetousk.github.io/lantern-deep/ (Chrome, Firefox, or Edge). Old version? Press Ctrl+Shift+R.
- **Android:** install **Obtainium**, tap **Add app**, and paste `https://github.com/acetousk/lantern-deep`. Obtainium shows each update.
- **Windows:** on the [Releases page](https://github.com/acetousk/lantern-deep/releases), download `lantern-deep-<version>-windows.zip`. Unzip it and run the game. (Windows may warn about an unknown app: click "More info" → "Run anyway".)
- **Linux:** on the [Releases page](https://github.com/acetousk/lantern-deep/releases), download `lantern-deep-<version>-linux-x86_64.tar.gz`. Unpack it and run the game.
- Mac and iPhone: use the web version.

## Credits
See [CREDITS.md](CREDITS.md).
