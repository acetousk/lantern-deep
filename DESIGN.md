# Lantern Deep

**One sentence:** You carry a lantern down a dark cave, floor by floor, to grab the Ember Relic.

## Basics
- 2D, turn-based dungeon crawler, seen from the top. The camera follows the player.
- Grid of 16×16 pixel tiles. Move in 4 directions.
- Players: 1–4. Play solo, or online co-op with GD-Sync: everyone is in the same cave.

## Co-op
- The host's game makes one seed number for the run. Every floor, its monsters and its potions come from it, so everyone gets the same cave.
- The host is the boss: it checks every move, runs the monsters, and tells everyone what happened.
- Friends join with a 4-digit room code. No names, no chat. Heroes are P1–P4 in palette colors.
- Shared vision: you see what any hero's lantern lights.
- 1 hero on the stairs = the whole team goes down.
- XP goes to whoever lands the kill. Potions go to whoever steps on them. Learned potion names are known by everyone.
- +2 monsters per floor for each extra player.
- Win together: anyone grabs the relic. A dead hero turns gray and watches a living friend. Everyone dead = you lose.
- If a player leaves, their hero goes away. If the host leaves, the game ends ("Host left").

## Turns and combat
- Every living hero does 1 action, in any order. Then every awake monster does 1 action.
- Bump into a monster to attack it.
- Chance to hit = 80% − the target's dodge. Damage is a range (for example 1–3).

## The cave
- 3 floors. Each floor is 32×24 tiles and is made new every run.
- 6–9 rooms on a 3×3 grid, joined by corridors 1 tile wide.
- A flood fill checks that the stairs can always be reached.
- Floors 1–2 have stairs down. Floor 3 has the Ember Relic.

## Seeing
- Fog of war: you see 6 tiles around you (shadowcasting, so walls block what you see).
- Tiles you saw before stay dim. Tiles you never saw are black.
- The lantern is a PointLight2D on the player.

## Player
- 20 HP, 1–3 damage.
- Wait (skip a turn): heal 1 HP every 10 turns while no monster is awake.
- Level up at 10 / 25 / 45 XP: +5 max HP, +1 damage, full heal.

## Potions
- 3 kinds. Each run gives every kind a new random color, so you don't know which is which until you drink it.
  - Healing ×3: heals you.
  - Sight ×2: shows the whole floor map.
  - Embers ×2: 4 damage to you, 6 damage to every monster next to you.
- 4 slots.

## Monsters
Monsters sleep until you come within 4 tiles. In v1.0 all of them move every turn.

| Monster | Floors | HP | Damage | XP | Special |
|---|---|---|---|---|---|
| Mire Slime | 1–2 | 4 | 1–2 | 2 | — |
| Cave Moth | 1–3 | 3 | 1–3 | 3 | 30% dodge |
| Bone Warden | 2–3 | 10 | 2–3 | 6 | Wakes at 6 tiles |

Monsters per floor: 4 / 6 / 7.

## Win and lose
- **Win:** grab the Ember Relic on floor 3.
- **Lose:** HP reaches 0. Permadeath: you start a new run.
- End screen shows the stats for the run.

## Screen (HUD)
HP, level and XP, floor number, 4 potion slots, a 3-line message log.

## Feel
- Moves slide in 0.06 seconds.
- Hit flash.
- Warm lantern light.

## Controls
| Action | Keyboard | Gamepad | Touch |
|---|---|---|---|
| Move | Arrows / WASD | D-pad | Tap the next tile, or the on-screen pad |
| Wait | Space | A | Wait button |
| Drink | 1–4 | — | Tap a slot |

## Art
- Made by `tools/make_sprites.py` (Pillow), using only the palette:
  tiles, player, 3 monsters, the relic (1 frame each), and a white potion that the code tints.
- UI in SVG. `icon.svg` for the icon.

## Palette: Ember Cave
| Color | Hex |
|---|---|
| Black-brown | `#1a1410` |
| Dark stone | `#3b2f2a` |
| Rock | `#6b5a4e` |
| Lantern orange | `#f2a33a` |
| Flame yellow | `#ffd966` |
| Slime green | `#7fae5a` |
| Blood red | `#c8443a` |
| Bone white | `#e8dcc4` |

## Sound
Made by `tools/make_sfx.py`: step, hit, miss, hurt, die, level_up, drink, stairs, relic, lose, click.
No sound before the first click or tap.

## Not in v1.0
- 2-frame idle animation
- Saved best floor
- Doors that block sight
- Relic guard (20 HP) on floor 3
- Floating damage numbers, 2px screen shake
- Slime moves every 2nd turn, moth moves randomly 1 in 3 turns
- Hunger, gold, shops, scrolls, armor, classes, bosses, more floors
