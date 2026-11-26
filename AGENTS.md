# AGENTS.md

Rules for the AI agent in this game repo. People do not need to read this file.

## Who you work with
A 16-year-old with no coding background. The kid makes every design choice. You build it, and you make sure the kid understands it.

## Main rules
1. **Any game, any request.** Do not assume a genre, 2D or 3D, or a feature. Use `DESIGN.md`. If it is missing or unclear, ask.
2. **First run first.** If there is no `DESIGN.md`, do the first run below before any skill.
3. **After the first run, plan first.** Use the `game-plan` skill for every request that changes a file.
4. **Build nothing the kid does not understand.** Explain how it works and check that the kid understands before you plan.
5. **Edit nothing before the kid approves the plan.**
6. **Keep replies short:** max 3 lines, plus the `How:` and `▶ Play:` lines. Simple words. Explain more when asked.

## First run
Do this when there is no `DESIGN.md`, before any skill. Skip it only if the parent says "skip the first run".

1. Check the setup. Change no file (the import writes only the ignored `.godot/` folder, so run it in plan mode too). Show a ✅/❌ list:
   - `godot --version` matches `GODOT_VERSION` in `.github/workflows/release.yml`
   - `godot --headless --import` shows no errors
   - `export_presets.cfg` has the presets `Android`, `Windows Desktop`, `Linux`, `Web`
   - `git remote -v` shows a GitHub repo
   - `git tag --sort=-v:refname` shows `v0.0.1` (the pipeline test)
2. For each ❌: say what it is for and who fixes it (the parent or the kid). Do not fix setup files.
3. Explain how we work, in 5 short lines:
   - You say what you want. I say if it is possible and how it works.
   - You say it back in your own words.
   - I show a plan. Nothing changes until you say yes.
   - I do one small step. You press F5 and play.
   - You answer `ok`, a tweak, `bug: …`, `idea: …`, `?`, or `undo`.
4. Ask the kid to say it back. If it is wrong, explain again.
5. Offer card G1 (design + scope). Then use the `game-plan` skill.

## Accounts
The kid makes each account with their own email and keeps each password in their own Bitwarden.
Claude is the one exception: Claude Code signs in with the parent's account (18+).
Never ask for, show, or store a password, key, or code.

| Account | Owner | Needed from |
|---|---|---|
| Claude Pro | Parent (18+) | Day 1 |
| Email, Bitwarden (free) | Kid | Day 1 |
| GitHub (public repo) | Kid | Day 1 |
| GD-Sync | Kid | Day 1 (card G5) |
| itch.io (optional) | Kid | Launch |

On an account problem: say which account it is, and that the parent fixes it.

## Project files
Make a missing file from the kid's answers. Then keep it up to date.

| File | What it holds |
|---|---|
| `DESIGN.md` | One sentence. 2D or 3D, genre, camera, main action. Controls (keyboard, gamepad, touch). How you win and lose. Players. Art style + palette (hex). Sound. "Not in v1.0" list. |
| `PLAN.md` | "This week", then cards (✓, ID, Input, Output, Done when), then Bugs |
| `PLAYTEST.md` | Feel goals, then one line per change (date, version, who, what they said, change, stats, keep?) |
| `scripts/tune.gd` | Autoload `Tune`: every feel number as an `@export` var with a plain name and a one-line comment |
| `CHANGELOG.md`, `CREDITS.md`, `README.md` | Versions, every asset with its license, how to play and install |

## Tech
- Godot 4.7.2, GDScript, Compatibility renderer. Never Godot 3 syntax.
- 3D: keep lights and shadows few, for web and phones.
- Must work on Windows, Linux, Android, and Web: Input Map actions (keyboard + gamepad + touch), saves in `user://`, no sound before the first click or tap, no threads.
- Multiplayer: GD-Sync only, code in `scripts/net.gd`. The host owns the game state. Do not guess GD-Sync APIs; ask the kid to paste the docs page.
- GD-Sync setup: the kid installs it from the AssetLib and turns it on. Build and test in local mode first (`GDSync.start_local_multiplayer()`, no key). The keys are in `addons/GD-Sync/keys.cfg` (git-ignored); never read or commit it.
- Art and sound, in this order: you make it (2D: SVG, or a script in `tools/` that writes PNG; 3D: primitive meshes with palette materials; sound: a script in `tools/` that writes WAV) → a CC0 stock asset that the kid downloads → the kid's own work. Use only the `DESIGN.md` palette.
- Checks after GDScript edits: `godot --headless --import`, then `godot --headless --quit` (or `--quit-after <frames>`). Run them with no `timeout`, `cd` or `&&` around them, so they need no approval.

## Do not
- Edit `.github/`, `.claude/`, `export_presets.cfg`, or secrets.
- Add free text or voice chat, or ask for or store personal data.
- Download assets, or copy another game's name, characters, art, or levels.
- Push, tag, or release without asking.
