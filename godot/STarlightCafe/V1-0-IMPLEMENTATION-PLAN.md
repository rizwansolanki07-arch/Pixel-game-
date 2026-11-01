# Starlight Café v1.0 — The Spirit Café

Status: implementation kickoff / planning baseline  
Base: `feature/full-game-expansion-wave1`  
Rule: this work stays isolated on `feature/starlight-cafe-v1-spirit-cafe`. Do not overwrite Chanderi Quest, the existing generator/tooling, or the current playable Starlight slice.

## Release goal

Turn the existing Starlight Café vertical slice into a stable, replayable cozy café-and-spirit RPG. Preserve the established 384×216 logical viewport, 2:1 isometric geometry, nearest-neighbour pixel rendering, current save compatibility, and mobile-first controls.

## Delivery order

### 0. Stabilize the base (must pass before feature work)
- [ ] Import the project with the repository's pinned Godot version and resolve all parser/import errors.
- [ ] Verify the current feature branch head and PR #5 changes are represented in this branch.
- [ ] Run a clean headless editor import and record the exact engine version and result.
- [ ] Add regression checks for legacy save loading, new save creation, and save/reload persistence.
- [ ] Keep Android export blocked until import and gameplay validation pass.

### 1. Café day loop
- [ ] Add explicit café states: closed, preparing, open, closing.
- [ ] Add a deterministic daily opening/closing schedule and prevent service outside open hours.
- [ ] Add customer queue/order lifecycle: arrive → order → prepare → serve → reward/relationship.
- [ ] Make customer patience, order timeout, and rewards data-driven.
- [ ] Persist café state safely without breaking older save files.

### 2. Cooking and recipe progression
- [ ] Replace the single hard-coded soup flow with a data-driven recipe catalog.
- [ ] Validate ingredient quantities before consuming any items.
- [ ] Add cooking stages and clear success/failure feedback.
- [ ] Unlock recipes through story, NPC relationships, and exploration.
- [ ] Add a recipe book UI usable with touch and keyboard.

### 3. Night spirits and relationships
- [ ] Keep Aoi and Ren's existing story flags and progression intact.
- [ ] Add spirit arrival conditions, dialogue state, favorite dishes, and rewards as data.
- [ ] Add relationship milestones with explicit, persisted unlocks.
- [ ] Ensure every quest/interaction is idempotent: completed rewards cannot be granted twice.
- [ ] Add tests for day/night gating and old-save defaults.

### 4. Café upgrades and presentation
- [ ] Add placement preview, rotate, cancel/undo, and collision feedback.
- [ ] Add meaningful upgrade effects (seating capacity, comfort, spirit affinity, recipe access).
- [ ] Replace placeholder actors/props incrementally with licensed, authored assets.
- [ ] Keep asset source and license metadata alongside imported assets.

### 5. Release candidate
- [ ] Test new save and legacy save paths.
- [ ] Test complete loop: gather → cook → open café → serve → spirit visit → quest reward → save → reload.
- [ ] Test touch controls, safe-area/layout, orientation, and performance on Android.
- [ ] Export APK only after validation; attach commit SHA, Godot version, export preset, and test notes.
- [ ] Keep PR in draft until all required checks pass.

## Engineering guardrails
- Unique stable IDs for recipes, customers, NPCs, quests, items, furniture, and story flags.
- Data-driven content; avoid adding more one-off hard-coded branches to the main gameplay controller.
- No completed quest or reward may reset or be granted twice.
- No disconnected locations or NPCs without a gameplay purpose.
- Save schema changes must use defaults/migrations and preserve existing saves.
- No unlicensed assets may ship.
- Every milestone must include validation evidence; code presence alone is not a runtime pass.

## First implementation target

Complete Phase 0 stabilization first. Do not start the café-management feature until the Godot import/parser check and save-compatibility checks pass on this branch.
