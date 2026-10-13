# Starlight Café — Full Game Expansion Plan

## Product direction
A cozy, story-first 2D pixel RPG for Android and PC. Yui reopens her late father's café in Greenhollow. Daytime is for village friendships, gathering, a small garden and café work; at night, spirits arrive for dishes that reconnect them with unfinished memories. The core loop is story + cooking + atmosphere, not combat.

## Locked technical/art direction
- Godot 4, 384×216 logical viewport, crisp nearest-neighbour pixel rendering.
- Existing 64×32 isometric floor presentation and 56 px Yui presentation sprite are retained until an intentional migration is tested.
- Reusable furniture is made as standalone props, not baked into terrain tiles.
- Handcrafted chunky pixel art: dark outlines, warm golden-brown wood, purple-brown shadows, controlled highlights.
- Mobile touch controls are first-class; keyboard remains available on PC.
- Keep Chanderi Quest separate; this repository/branch is only Starlight Café.
- Never call an untested APK a final commercial release. Keep existing content and save compatibility.

## Workstreams and acceptance gates

### 1. Visual direction and environment
- [x] First visual polish pass: lantern glow, window reflections, table highlights, serviceware, floor details.
- [ ] Review café at native pixel scale in day and night; remove any detail that hides gameplay targets.
- [ ] Replace placeholder block props with authored, reusable sprite assets: tables, chairs, shelves, stove, kettle, jars, plants, rugs, lanterns and signs.
- [ ] Create consistent café exterior, market, inn, shrine, well, garden and forest-edge environment sets.
- [ ] Add restrained ambient effects: candle flicker, window glow, drifting motes, rain/fog only where readable.
- [ ] Verify every sprite has transparent clean edges, no anti-aliasing, correct pivots and no alpha fringe.

### 2. Character art and animation
- [ ] Lock Character DNA sheets for Yui, Mina, Bram, Aoi, Ren and Hana (palette, silhouette, clothing, proportions).
- [ ] Replace fallback silhouette with consistent 4-direction idle/walk sprite sheets; validate frame dimensions and pivots.
- [ ] Add small contextual animations: cooking, serving, watering, harvesting and spirit arrival.
- [ ] Keep character shadows and feet aligned to the same ground baseline.

### 3. Story and quests
- [ ] Chapter 1: reopen Papa's café, gather moon mushroom, cook for Aoi, recover her first memory.
- [ ] Chapter 2: restore the forgotten garden, meet Hana, grow ingredients and discover a clue about Papa's final menu.
- [ ] Chapter 3: help Ren recover his dawn memory; reveal the link between the café and the village shrine.
- [ ] Branching relationship scenes and meaningful stored story flags; completed quests never reset.
- [ ] All story dialogue supports English and Hinglish/Roman Hindi without changing technical IDs.

### 4. NPC schedules and relationships
- [x] Add persistent NPC, schedule and relationship data foundation for Yui, Mina, Bram, Aoi, Ren and Hana.
- [x] Add distinct procedural pixel-art actors for village residents and the Aoi/Ren night spirits.
- [x] Move Mina, Bram and Hana between schedule landmarks while respecting village building collision bounds.
- [x] Add character-specific conversations and relationship progress for village residents and spirit memories.
- [ ] Replace procedural actors with authored 4-direction sprite sheets and walk/idle animations.
- [ ] Add dedicated shop affordances and richer daily dialogue variants; no meaningless NPCs.
- [ ] Relationship milestones unlock additional recipes, memories, furniture or side quests.

### 5. Farming and gathering
- [x] Add persistent crop plot state, crop catalog, planting/watering/harvest API.
- [x] Wire two garden plots into village interactions with planting, watering, growth-stage feedback and harvesting.
- [ ] Add day advancement/sleep flow, season rules, watering feedback and harvest rewards.
- [ ] Keep farming smaller than cooking/story; every crop should have a recipe, sale or quest purpose.

### 6. Furniture and café upgrades
- [x] Add a reusable furniture catalog and ownership/placement state foundation.
- [x] Add a touch-friendly furniture catalog/shop with coin costs, selection and buy/place actions.
- [x] Render placed furniture as standalone pixel-art props and persist placement in world saves.
- [x] Add 16×8 projected-grid snapping, footprint-based overlap checks across different furniture types, and validation against the café floor/static props.
- [ ] Add placement preview, rotate/undo and upgrade effects.
- [ ] Upgrades change customer capacity, comfort, spirit affinity or recipe access—not just decoration.
- [ ] Furniture remains standalone, license-safe assets and must not be merged into terrain tiles.

### 7. Cooking, inventory and economy
- [ ] Expand recipes through data definitions, ingredient validation, cook progress, dish quality and serving feedback.
- [ ] Add ingredient shop, selling, prices, daily orders and a balanced coin economy.
- [ ] Inventory/recipe book show item icons, counts, unlock states and clear empty states.
- [ ] Prevent duplicate rewards and validate inventory after save migration.

### 8. World layout and navigation
- [ ] Build connected café, Greenhollow village, garden, forest edge, shrine and market routes.
- [ ] Add transition gates, collision bounds, return points, map landmarks and interaction prompts.
- [ ] Keep locations visually distinct but reuse the same palette, tile grid and character scale.
- [ ] Add new areas only after the current slice is playable end-to-end.

### 9. Audio, UX and accessibility
- [ ] Café ambience, soft cooking sounds, footsteps, spirit motifs and restrained day/night music.
- [ ] Volume controls, dialogue speed, text readability, language toggle and clear mobile hit targets.
- [ ] Avoid loud UI spam; keep screen effects subtle and disableable.

### 10. Save, QA and release
- [x] Save schema extended to include world-director state while preserving old-save defaults.
- [ ] Test fresh save, legacy save, reload, quest completion, crops, relationships, furniture and currency.
- [ ] Run Godot headless parse/import checks and capture day/night screenshots.
- [ ] Verify Aoi/Ren night interactions and NPC collision/pathing in a running Godot build; code changes are not runtime-verified yet.
- [ ] Export APK, install on physical Android, test joystick/interactions/rotation/performance.
- [ ] Merge only after review and passing checks; attach build metadata and test notes.

## Current implementation wave
This branch adds a modular world director for story flags, NPC schedules/relationships, farming state, furniture ownership/placement, quest data and currency; connects it to the existing autoload/save pipeline; and connects village conversations/customer serving to relationship/reward progression. It includes a touch-friendly furniture catalog/shop, buy/place interactions, separate pixel-art furniture rendering, distinct Aoi/Ren night-spirit interactions, and collision-aware village resident movement. Furniture placement is persisted in saves. Remaining work includes placement preview/rotate/undo, authored sprite sheets and animations, richer maps/story scenes, in-engine tests and Android QA. This is still a work in progress, not a claim that the full game is finished.

## Definition of done
A player can start a new save, reopen the café, move between connected locations, meet scheduled NPCs, gather and grow ingredients, cook and serve dishes, experience a spirit memory, upgrade/place furniture, progress story quests, and save/load without losing progress. Both day and night are visually checked at native pixel scale and on a real Android device.
