# Chanderi Quest Runtime

This directory is the new game layer. It is intentionally separate from the existing Aether Resonance game.

## Planned modules
- core/GameState
- core/EventBus
- core/SaveManager
- world/MapManager
- world/Collision
- world/WorldState
- player/PlayerController
- interaction/InteractionManager
- dialogue/DialogueManager
- quests/QuestManager
- inventory/InventoryManager
- ui/GameUI

The first playable slice will use authored map data and stable IDs for every NPC, object, exit and event.


## Implemented foundation
- Persistent local SaveManager
- EventBus for decoupled game events
- Central GameState with player, quest, inventory, world flags and time
- MapManager and collision helpers
- Stable-ID InteractionManager
- QuestManager with step/completion events
- InventoryManager with add/remove/has operations

## Build order
1. Authored village + interior map runtime
2. Character sprite integration
3. Dialogue/choice runtime
4. Inventory UI and item pickup
5. Combat and enemy encounters
6. Day/night NPC schedules
7. Save/load integration across every system
8. Android packaging for Chanderi Quest
