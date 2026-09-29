# Starlight Café — Raat ka Menu

Isometric cooking + story RPG foundation and first playable vertical-slice prototype.

## Current playable loop
1. Move Yui around the café with WASD.
2. Gather mushroom, herbs, milk and salt from marked spots.
3. Approach the counter and cook Moonlight Mushroom Soup.
4. Press N to enter night; Aoi appears.
5. Serve the prepared soup to Aoi to advance her story by one fragment.
6. Press P to save; relaunching restores day, phase, position, inventory and spirit progress.

## Controls
- WASD: move
- E: interact / gather / cook / serve
- N: force night
- D: force day
- P: save

## Locked visual rules
- Isometric 2:1 floor geometry.
- Character reference scale: 56 px tall for a 165 cm human.
- Base floor tile: 64x32 px representing roughly 90x90 cm.
- 8 facing directions; five frames per facing (idle + four walk).
- Pixel-perfect nearest filtering.
- Furniture is modular and placed as separate game objects, not baked into a background.
- Day/night palette and lighting are gameplay systems.

## Scope note
The current vertical slice uses code-drawn placeholder art so the gameplay loop can be tested before final PNG furniture, character and environment assets are imported.
