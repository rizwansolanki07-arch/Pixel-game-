# Starlight Café — Raat ka Menu

Isometric cooking + story RPG — first playable vertical-slice foundation.

## Playable loop

1. Move Yui around the café with **WASD** or the on-screen mobile joystick.
2. Gather moon mushroom, village herb, milk and salt.
3. Approach the counter and press **E** / mobile interact to start cooking.
4. Wait for the cooking progress bar to finish.
5. Press **N** for the first night; **Aoi** appears.
6. Serve the prepared Moonlight Mushroom Soup.
7. Read Aoi's multi-line dialogue and advance her first memory fragment.
8. Press **P** to save and relaunch to restore the Starlight state.

## Controls

- **WASD** — move
- **E** — interact / gather / cook / serve / advance dialogue
- **N** — force night
- **D** — force day
- **P** — save
- **Mobile** — virtual joystick + E button

## Current architecture

- `StarlightGameState.gd` — persistent gameplay state.
- `DayNightManager.gd` — day/night cycle.
- `StarlightSaveManager.gd` — Starlight-specific save file.
- `StarlightCafe.gd` — vertical-slice gameplay controller.
- `StarlightDialogue.gd` — reusable dialogue presentation.
- `StarlightTouchControls.gd` — mobile movement/interact layer.
- JSON data — recipes and spirits.

## Locked visual rules

- Isometric 2:1 floor geometry.
- Character reference scale: **56 px = 165 cm**.
- Base floor tile: **64x32 px ≈ 90x90 cm**.
- 8 facing directions.
- 5 frames per facing (idle + four walk).
- Pixel-perfect / nearest filtering.
- Furniture is modular, separate from backgrounds.
- Day/night palette and lighting are gameplay systems.
- Café furniture must match the established chunky, handcrafted pixel-art reference style.

## Art pipeline rule

The current slice intentionally uses code-drawn placeholder shapes so gameplay can be validated first. The next production pass replaces each placeholder with modular premium PNG assets without changing the gameplay scale rules.

## Next production milestone

**Premium asset integration:** Yui sprite set → wall/floor modules → table/chair/counter → kitchen props → lamps/window → collision map → dialogue portraits → Android touch polish.
