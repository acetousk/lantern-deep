---
name: game-plan
description: Use for every request in this game repo that changes a file - a new game, feature, bug, feeling ("too hard"), art, sound, or release. Works out the request, checks the kid understands, plans, and gets approval before any edit.
---

# Game plan: understand → plan → approve → build

## 0. First run done?
No `DESIGN.md`, and the parent did not say "skip the first run"? Stop. Do the first run in `AGENTS.md`.

## 1. Work out the request
Sort it, then go on:

| Request | Do |
|---|---|
| A question | Answer it. No plan. |
| A feeling ("too hard", "boring"), or "Tune round" | Section 6 |
| A bug | Ask for the exact error or a screenshot. Then go on. |
| A new game (first run done, card G1) | Section 5 |
| Anything else | Go on |

Read only the files you need. Find how to do it in Godot 4.7.2 on all 4 platforms.

## 2. Say if it is possible
- **Yes:** how it works, in 2–4 plain lines.
- **Yes, but big:** about how many steps, and a smaller version that fits.
- **Not possible here:** why (engine, platform, budget, or an `AGENTS.md` rule), how the real thing works, and the closest option.

Not in `DESIGN.md`? Ask: add it now, or put it in "Not in v1.0"?

## 3. Check understanding
1. Explain the idea, not the code. Use an example from games the kid knows.
2. Ask the kid to say in their own words how it will work.
3. Wrong or unsure? Explain another way. Repeat.
4. Do not plan until the kid has it right.

## 4. Plan, approve, build
1. Write cards: ID, Input, Output, Done when. One card = 5–30 minutes. Bigger → more cards.
2. Give each card numbered steps. One step = one change the kid can see, about 1 minute of your work.
3. Show **Input / Output / Steps / Test**. Ask "Approve this plan?" and stop.
4. After a yes, add the cards to `PLAN.md`. Do **one step**, run the checks, then end with:
   `How: <one line>` and `▶ Play: <what to do> — look for <what>`. Stop.
5. Act on the kid's answer:
   - `ok` → the next step
   - a tweak ("faster") → change only that, then ▶ again
   - `bug: …` → fix it if it is inside the Output; if not, add it to Bugs
   - `idea: …` → add it to "Not in v1.0", then go on
   - `?` or `why?` → explain; do no more steps until the kid understands
6. Change only the Output files. Need more? Stop and ask.
7. After the last step, check "Done when", tick the card, and say "Commit now."

## 5. A new game: the first playable
Budget: about 75 minutes of your work, about 65 steps. Result: start → play → win or lose → play again, with sound, online with 2–4 players, on all 4 platforms.

| Card | Budget | Steps |
|---|---|---|
| G1 Design + scope | 5 min | One question at a time: 2D or 3D, what you are, how you move, main action, win, lose, what the host runs online, a palette from 3 choices → `DESIGN.md`. Then count the steps for G2–G7. Over the budget → the kid cuts. |
| G2 Core loop | 15 min | World → `Tune` → player → movement → main action → camera → tune → stay inside the play area |
| G3 Goal | 10 min | One goal → progress display → enough for 1–3 minutes → win → a small effect |
| G4 Pressure | 10 min | One threat → its cost + a short safe time → display → lose → a 2nd threat or more speed → tune |
| G5 Online | 15 min | The kid installs GD-Sync → `scripts/net.gd` in local mode → host or join a room by a 4-digit code → sync the players → the host runs the game state → a 2-instance test. The online test with a key comes after `v0.1.0`. |
| G6 Flow + sound + touch | 12 min | Start screen ("Click or tap to start") → end screen → play again 3 times → touch controls → write `tools/make_sfx.py` (WAV) → sounds in the game → the kid plays a full game and names one fix |
| G7 Ship | 8 min | Title + icon → the fix → `CHANGELOG.md` → ask to tag `v0.1.0` → the kid checks speed on the web link and the phone |

First playable: no animation, saving, or extra levels.
Over the budget? Skip the tune and effect steps.

Later milestones: when the kid names a goal ("feels good", "online with a key", "more levels", "polish", "launch"), make cards for this game. Use sections 2–4.

## 6. A feeling: the tune loop
1. Name 1–3 `Tune` values that can cause the feeling, and why. No value fits? Make a card instead.
2. Change **one** value. Say old → new. Ask the kid to play a full run.
3. Ask "keep or undo?". Add one line to `PLAYTEST.md`. Include the stats from `user://stats.json` if they exist.

## 7. Release (when asked)
Suggest the next tag (fix → `v1.2.1`, feature → `v1.3.0`). Add a line to `CHANGELOG.md`. Ask before `git tag` and `git push`.
